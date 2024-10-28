import { LightningElement, wire, api, track } from 'lwc';
import getContentAttachments from '@salesforce/apex/AttachmentsInEventoRoyaltyHandler.getContentAttachments';

export default class EventoRoyaltyAttachments extends LightningElement {

    @api recordId;
    @api isEventoRoyalty = false;
    @track files = [];
    
    columns = [
        {
            label: 'Name',
            fieldName: 'Name',
            type: 'button', 
            typeAttributes: { 
                label: { fieldName: 'Name' }, 
                name: 'view',
                title: 'View',
                variant: 'base',
                iconName: 'utility:preview'
            }
        },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'date',
            typeAttributes: {
                year: "numeric",
                month: "short",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }
        }
    ];

    @wire(getContentAttachments, { recordId: '$recordId' })
    wiredContentAttachments({ error, data }) {
        if (data) {
            this.files = data.attachments.map(file => ({
                ...file,
                CreatedDate: new Date(file.CreatedDate)
            })).sort((a, b) => b.CreatedDate - a.CreatedDate);
            this.isEventoRoyalty = data.isEventoRoyalty;
        } else if (error) {
            console.error('Error fetching data:', error);
        }
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'view':
                this.navigateToRecord(row);
                break;
            default:
                break;
        }
    }

    navigateToRecord(row) {
        window.open(row.DownloadLink, "_blank");
    }

    get headerTitle() {
        return `Anexos (${this.files.length})`;
    }

}