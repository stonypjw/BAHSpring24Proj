@isTest
private class InvoiceHandlerTest {

    /*
        Need Opp with an Owner -> Data factory
        Invoice__c linked to Opp (When opp is Closed Won Invoice is auto created)

        Test-> Insert or Update of the Invoice record

        Check -> Query Invoice__Share to check results
    */

    @isTest
    public static void shareWithOppOwnerTest(){
        List<Account> accList = TestDataFactory.createAcc(1);
        insert accList;

        Opportunity opp = TestDataFactory.createOpp(accList[0]);
        Test.startTest();
        opp.StageName = 'Closed Won';
        insert opp;
        Test.stopTest();

        // Query to see if Invoice was created automatically
        List<Invoice__c> invList = [SELECT Id, OwnerId, Opportunity__c FROM Invoice__c];
        Assert.areNotEqual(0, invList.size(), 'No Invoice__c records created or returned from query');

        // Query to see if Invoice__Share was created
        List<Invoice__Share> invShare = [SELECT Id, UserOrGroupId, ParentId, RowCause, AccessLevel FROM Invoice__Share];
        Assert.areNotEqual(0, invShare.size(), 'No invShare records created or returned from query');


        // Query for SVP Customer Group as we have sharing rule for that
        Group SVPGroup = [SELECT ID, DeveloperName FROM Group WHERE DeveloperName = 'SVPCustomerServiceSupportA' LIMIT 1]; 

        for(Invoice__Share invs : invShare){
            if(invs.RowCause.equals('Opportunity_Owner__c')){
                Assert.areEqual(invList[0].Id, invs.ParentId, 'ParentId does not Match Invoice Id');
                Assert.areEqual('Read', invs.AccessLevel, 'AccessLevel does not Match Read');
            } 
            if(invs.RowCause.equals('Rule')){
                Assert.areEqual(SVPGroup.Id, invs.UserOrGroupId, 'ParentId does not Match Invoice Id');
                Assert.areEqual('Read', invs.AccessLevel, 'AccessLevel does not Match Read');
            } 
            if(invs.RowCause.equals('Owner')){
                Assert.areEqual(invList[0].OwnerId, invs.UserOrGroupId, 'ParentId does not Match Invoice Id');
                Assert.areEqual('All', invs.AccessLevel, 'AccessLevel does not Match All');
            }
        }

    }

    @isTest
    public static void shareWithOppOwnerUpdateTest(){
        List<Account> accList = TestDataFactory.createAcc(1);
        insert accList;

        Opportunity opp = TestDataFactory.createOpp(accList[0]);

        opp.StageName = 'Closed Won';
        insert opp;


        // Query to see if Invoice was created automatically
        List<Invoice__c> invList = [SELECT Id, OwnerId, Opportunity__c FROM Invoice__c];
        Assert.areNotEqual(0, invList.size(), 'No Invoice__c records created or returned from query');
        invList[0].Amount__c = 44444444.44;
        Test.startTest();
        update invList;
        Test.stopTest();

        // Query to see if Invoice__Share was created
        List<Invoice__Share> invShare = [SELECT Id, UserOrGroupId, ParentId, RowCause, AccessLevel FROM Invoice__Share];
        Assert.areNotEqual(0, invShare.size(), 'No invShare records created or returned from query');


        // Query for SVP Customer Group as we have sharing rule for that
        Group SVPGroup = [SELECT ID, DeveloperName FROM Group WHERE DeveloperName = 'SVPCustomerServiceSupportA' LIMIT 1]; 

        for(Invoice__Share invs : invShare){
            if(invs.RowCause.equals('Opportunity_Owner__c')){
                Assert.areEqual(invList[0].Id, invs.ParentId, 'ParentId does not Match Invoice Id');
                Assert.areEqual('Read', invs.AccessLevel, 'AccessLevel does not Match Read');
            } 
            if(invs.RowCause.equals('Rule')){
                Assert.areEqual(SVPGroup.Id, invs.UserOrGroupId, 'ParentId does not Match Invoice Id');
                Assert.areEqual('Read', invs.AccessLevel, 'AccessLevel does not Match Read');
            } 
            if(invs.RowCause.equals('Owner')){
                Assert.areEqual(invList[0].OwnerId, invs.UserOrGroupId, 'ParentId does not Match Invoice Id');
                Assert.areEqual('All', invs.AccessLevel, 'AccessLevel does not Match All');
            }
        }

    }

}