**Attachments in Approval Process LWC**

**Description**
 - This project enables users to view and download Attachments and ContentVersions of child records in approval layouts via a Lightning Web Component (LWC) and an Apex handler. Although the Evento_Royalty__c object is used as an example, the code is scalable to fit other objects, with query adjustments and conditional rendering based on the approved objects.

**Implementation**
 - **Approval Layouts and Record Page Configuration:**
    - Approval layouts include the eventoRoyaltyAttachments LWC, preconfigured in the flexipage files provided.
    - The Evento_Royalty_Record_Page also contains the LWC to display attachments on the main record detail page.
  - **Permissions:**
    - Ensure that users have access to view and download documents.

**File Structure**
 - **Apex Handler:**
   - AttachmentsInEventoRoyaltyHandler manages file retrieval logic, detects object type, and generates download links.
 - **LWC:**
   - eventoRoyaltyAttachments displays attachments and content versions.
 - **Approval Layouts:**
   - Configured to display files on the relevant object.

**Usage**
 - The LWC presents attachments and content versions for records under approval, allowing direct download.
