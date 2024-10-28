/**
 * @description       : Test class for AttachmentsInEventoRoyaltyHandler.
 *                      This test validates that the handler correctly retrieves attachments and content versions 
 *                      associated with Evento_Royalty__c records and their child Evento_Royalty_Item__c records.
 * @author            : pablo.fraquia@cloudgaia.com
 * @group             : 
 * @last modified on  : 10-28-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@isTest
public class AttachmentsInEventoRoyaltyHandlerTest {

    /**
     * Test setup method to create data for testing.
     * Creates an Account, associated Saldo_por_safra__c, Evento_Royalty__c and Evento_Royalty_Item__c records,
     * and inserts test Attachment and ContentVersion records for testing.
     */
    @TestSetup
    static void makeData() {
        // Create and insert test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create and insert Evento_Royalty__c related to the account
        Evento_Royalty__c evento = new Evento_Royalty__c(Name = 'Evento', 
                                                         Cuenta__c = acc.Id);
        insert evento;

        // Create and insert Evento_Royalty_Item__c related to Evento_Royalty__c
        Evento_Royalty_Item__c item = new Evento_Royalty_Item__c(Evento_Royalty__c = evento.Id, 
                                                                 Valor__c = 1000);
        insert item;
        
        // Create and insert an Attachment for Evento_Royalty_Item__c
        Attachment testAttachment = new Attachment(Name = 'Test Attachment.png', 
                                                   Body = Blob.valueOf('Test Body 1'), 
                                                   ParentId = item.Id);
        insert testAttachment;

        // Create and insert a ContentVersion for Evento_Royalty_Item__c
        ContentVersion cv = new ContentVersion(Title = 'Test Document.png', 
                                               VersionData = Blob.valueOf('Test Body 2'), 
                                               PathOnClient = 'Test Document.png', 
                                               IsMajorVersion = true, 
                                               Show_File__c = true);
        insert cv;
        
        // Retrieve ContentDocumentId for linking to Evento_Royalty_Item__c
        cv = [SELECT Id, ContentDocumentId 
              FROM   ContentVersion 
              WHERE  Id = :cv.Id 
              LIMIT  1];
        
        // Create and insert ContentDocumentLink to associate ContentDocument with Evento_Royalty_Item__c
        ContentDocumentLink contentLink = new ContentDocumentLink(LinkedEntityId = item.Id, 
                                                                  ContentDocumentId = cv.ContentDocumentId, 
                                                                  ShareType = 'V', 
                                                                  Visibility = 'AllUsers');
        insert contentLink;
    }

    /**
     * Test method for validating the retrieval of attachments.
     * This test verifies that the handler correctly retrieves attachments and content versions 
     * for a given Evento_Royalty__c record, and that the response data is as expected.
     */
    @isTest
    static void testAttachmentRetrieval() {
       
        Evento_Royalty__c evento = [SELECT Id FROM Evento_Royalty__c LIMIT 1];
        
        Test.startTest();
            AttachmentsInEventoRoyaltyHandler.ResponseWrapper response = AttachmentsInEventoRoyaltyHandler.getContentAttachments(evento.Id);
        Test.stopTest();   

        // Validate that the response is not null and contains the expected number of attachments
        Assert.isNotNull(response, 'The attachments list should not be null');
        Assert.areEqual(2, response.attachments.size(), 'The number of attachments does not match the expected size');
    }
}
