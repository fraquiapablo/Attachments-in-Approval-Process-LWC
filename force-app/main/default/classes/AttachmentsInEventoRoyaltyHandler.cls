/**
 * @description       : Handler class for retrieving attachments and content versions associated with Evento_Royalty__c records.
 *                      Designed to support LWC component rendering attachments on approval layouts.
 * @author            : pablo.fraquia@cloudgaia.com
 * @group             : 
 * @last modified on  : 10-28-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class AttachmentsInEventoRoyaltyHandler {

    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getContentAttachments(Id recordId) {
    // Wrapper to hold response data, including attachments and object type verification
        ResponseWrapper response = new ResponseWrapper();
        Id recordObjetcId;
        response.isEventoRoyalty = false;
        // Determine object type to check if record is eligible for processing
        String mySObject = getObjectType(recordId);

        if(mySObject == 'ProcessInstanceStep' || mySObject == 'ProcessInstanceWorkitem') {
            Id recId;

            // Retrieve TargetObjectId if record is part of an approval process
            if(mySObject == 'ProcessInstanceWorkitem') {
                recId = [SELECT  Id, ProcessInstance.TargetObjectId 
                         FROM    ProcessInstanceWorkitem  
                         WHERE   Id =: recordId].ProcessInstance.TargetObjectId;
            } else if (mySObject == 'ProcessInstanceStep') {
                recId = [SELECT  Id, ProcessInstance.TargetObjectId 
                         FROM    ProcessInstanceStep 
                         WHERE   Id =: recordId].ProcessInstance.TargetObjectId;
            }

            String objectType =  getObjectType(recId); 
            if(objectType == 'Evento_Royalty__c') {
                recordObjetcId = recId;
                response.isEventoRoyalty = true;
            }             
            
        } else {
            // For direct Evento_Royalty__c records
            recordObjetcId = recordId;
            response.isEventoRoyalty = true;
        }

        List<ContentAttachmentWrapper> results = new List<ContentAttachmentWrapper>();
        Set<Id> recordsId = new Set<Id>();

        // Retrieve child Evento_Royalty_Item__c records
        for(Evento_Royalty_Item__c item : [SELECT Id 
                                           FROM   Evento_Royalty_Item__c 
                                           WHERE  Evento_Royalty__c = :recordObjetcId]) {
            recordsId.add(item.Id);
        }

        // Retrieve attachments for child records
        for(Attachment a : [SELECT  Id, Name, LastModifiedDate 
                            FROM    Attachment 
                            WHERE   ParentId IN :recordsId]) {
            results.add(new ContentAttachmentWrapper(a.Id, a.Name, 
                                                     String.valueOf(a.LastModifiedDate), 
                                                     createDownloadLink(a.Id, false)));
        }

        Set<Id> contentDocumentIds = new Set<Id>();

        // Retrieve ContentDocumentLinks for child records
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId 
                                       FROM   ContentDocumentLink 
                                       WHERE  LinkedEntityId IN :recordsId]) {                                        
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        // Retrieve ContentVersion for latest versions of ContentDocuments
        if (!contentDocumentIds.isEmpty()) {
            for(ContentVersion cv : [SELECT Id, Title, FileExtension, ContentDocumentId, CreatedDate
                                     FROM   ContentVersion 
                                     WHERE  ContentDocumentId IN :contentDocumentIds 
                                     AND    IsLatest = true]) {
                results.add(new ContentAttachmentWrapper(cv.Id, cv.Title, 
                                                         String.valueOf(cv.CreatedDate), 
                                                         createDownloadLink(cv.Id, true)));
            }
        }
       
        response.attachments = results; 
        return response;
    }

    /**
     * Returns the SObject type of a given record Id.
     */
    @AuraEnabled(cacheable=true)
    public static String getObjectType(String recordId) {
        SObjectType objectType = Id.valueOf(recordId).getSObjectType();
        return String.valueOf(objectType);
    }

    /**
     * Constructs a download link based on the attachment type.
     * @param fileId - Id of the file (Attachment or ContentVersion).
     * @param isContentVersion - Boolean indicating if the file is a ContentVersion.
     * @return - Download link as a String.
     */
    private static String createDownloadLink(Id fileId, Boolean isContentVersion) {
        return isContentVersion ? '/sfc/servlet.shepherd/version/download/' + fileId
                                : '/servlet/servlet.FileDownload?file=' + fileId;
    }

    /**
     * Wrapper class to structure response data for attachments and content versions.
     */
    public class ResponseWrapper {
        @AuraEnabled public List<ContentAttachmentWrapper> attachments;
        @AuraEnabled public Boolean isEventoRoyalty;
    }

    /**
     * Wrapper class for each attachment or content version entry.
     */    
    public class ContentAttachmentWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String CreatedDate;
        @AuraEnabled public String DownloadLink;

        public ContentAttachmentWrapper(String id, String name, String day, String downloadLink) {
            this.Id = id;
            this.Name = name;
            this.CreatedDate = day;
            this.DownloadLink = downloadLink;
        }
    }
}