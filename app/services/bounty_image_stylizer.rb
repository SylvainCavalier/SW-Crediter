require "net/http"
require "json"
require "base64"
require "uri"
require "mini_magick"

class BountyImageStylizer
  API_URL  = "https://api.replicate.com/v1/models/black-forest-labs/flux-kontext-pro/predictions".freeze
  PROMPT   = "Add a subtle holographic sci-fi overlay to this photo. Keep the original photo, the person's face, pose, clothing, background and composition strictly identical - do not redraw, do not restyle, do not change the character. Only add: a light cyan-blue holographic tint, faint horizontal scanlines across the whole image, a soft neon glow on the silhouette edges, and very subtle digital glitch artifacts. The result must look like the same photo viewed through a futuristic hologram projector.".freeze
  POLL_INTERVAL = 2
  MAX_WAIT      = 90

  class StylizationError < StandardError; end

  def self.call(bounty)
    new(bounty).call
  end

  def initialize(bounty)
    @bounty = bounty
  end

  def call
    return unless ENV["REPLICATE_API_KEY"].present?
    return unless @bounty.image.attached?

    prediction = create_prediction
    final = wait_for_completion(prediction)

    output_url = Array(final["output"]).first || final["output"]
    raise StylizationError, "No output from Replicate" if output_url.blank?

    replace_attachment(output_url)
  rescue StylizationError, Net::OpenTimeout, Net::ReadTimeout, JSON::ParserError => e
    Rails.logger.error("[BountyImageStylizer] #{e.class}: #{e.message}")
    nil
  ensure
    finalize!
  end

  def finalize!
    @bounty.update_columns(stylizing: false) if @bounty.persisted?
    @bounty.broadcast_image_update
  rescue => e
    Rails.logger.error("[BountyImageStylizer] finalize failed: #{e.class}: #{e.message}")
  end

  private

  def create_prediction
    body = {
      input: {
        prompt: PROMPT,
        input_image: data_uri,
        output_format: "jpg"
      }
    }

    response = post_json(API_URL, body, extra_headers: { "Prefer" => "wait=60" })
    raise StylizationError, "Replicate create failed: #{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  def wait_for_completion(prediction)
    return prediction if final_status?(prediction["status"])

    poll_url = prediction.dig("urls", "get")
    raise StylizationError, "No poll URL" if poll_url.blank?

    deadline = Time.now + MAX_WAIT
    loop do
      sleep POLL_INTERVAL
      response = get_json(poll_url)
      raise StylizationError, "Replicate poll failed: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      prediction = JSON.parse(response.body)
      return prediction if final_status?(prediction["status"])
      raise StylizationError, "Timed out waiting for Replicate" if Time.now > deadline
    end
  end

  def final_status?(status)
    %w[succeeded failed canceled].include?(status)
  end

  def data_uri
    bytes = oriented_bytes
    "data:image/jpeg;base64,#{Base64.strict_encode64(bytes)}"
  end

  # Bake the EXIF orientation into the actual pixels: Replicate (and most
  # image pipelines) ignore the EXIF Orientation tag, so a portrait phone
  # photo gets fed in sideways otherwise.
  def oriented_bytes
    raw = @bounty.image.download
    image = MiniMagick::Image.read(raw)
    image.auto_orient
    image.strip
    image.format("jpg")
    image.to_blob
  rescue => e
    Rails.logger.warn("[BountyImageStylizer] auto_orient failed (#{e.class}: #{e.message}), sending raw bytes")
    raw
  end

  def replace_attachment(url)
    uri = URI.parse(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 30) do |http|
      http.get(uri.request_uri)
    end
    raise StylizationError, "Download failed: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    original_filename = @bounty.image.blob.filename.to_s
    stylized_filename = "stylized_#{original_filename.sub(/\.[^.]+\z/, '')}.jpg"

    @bounty.image.purge
    @bounty.image.attach(
      io: StringIO.new(response.body),
      filename: stylized_filename,
      content_type: "image/jpeg"
    )
  end

  def post_json(url, body, extra_headers: {})
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 75, open_timeout: 10) do |http|
      request = Net::HTTP::Post.new(uri.request_uri, default_headers.merge(extra_headers).merge("Content-Type" => "application/json"))
      request.body = body.to_json
      http.request(request)
    end
  end

  def get_json(url)
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 30, open_timeout: 10) do |http|
      http.request(Net::HTTP::Get.new(uri.request_uri, default_headers))
    end
  end

  def default_headers
    {
      "Authorization" => "Bearer #{ENV['REPLICATE_API_KEY']}",
      "Accept" => "application/json"
    }
  end
end
