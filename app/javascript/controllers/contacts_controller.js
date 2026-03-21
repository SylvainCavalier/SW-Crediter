import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  removeContact(event) {
    event.preventDefault()
    const contactId = event.currentTarget.dataset.contactId
    
    if (confirm("Êtes-vous sûr de vouloir supprimer ce contact ?")) {
      fetch(`/contacts/remove?contact_id=${contactId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        }
      })
    }
  }
}
