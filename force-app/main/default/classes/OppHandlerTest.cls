@isTest
public class OppHandlerTest {

    @isTest
    static void ApplyNamingConventionTest(){

        List<Account> accList = TestDataFactory.createAcc(1);
        insert accList;

        Opportunity testOpp = TestDataFactory.createOpp(accList[0]);
        insert testOpp;

        List<Opportunity> resultOppList = [SELECT Id, Name, Type, CloseDate FROM Opportunity LIMIT 1];

        // Recreate the Naming Convention to test as the DueDate will change with each Test Run.
        String nameChecker = accList[0].Name + ' - ' + resultOppList[0].Type + ' - ' + 
                            String.valueOf(resultOppList[0].CloseDate.month())  + '/' + String.valueOf(resultOppList[0].CloseDate.year());
        Test.startTest();
        Assert.areNotEqual('Test Opp', resultOppList[0].Name, 'Name is not equal test failed: ' + resultOppList[0].Name);
        Assert.areEqual(nameChecker, resultOppList[0].Name, 'Name is equal test failed: ' + resultOppList[0].Name);
        Test.stopTest();

    }

    @isTest
    static void createInvoiceFromOppInsertTest(){

        List<Account> accList = TestDataFactory.createAcc(1);
        insert accList;

        Opportunity testOpp = TestDataFactory.createOpp(accList[0]);
        testOpp.StageName = 'Closed Won';
        insert testOpp;

        List<Invoice__c> resultList = [SELECT Id FROM Invoice__c];
        // Only 1 Invoice should be created on insert

        Test.startTest();
        Assert.areEqual(1, resultList.size(), 'Result List size is greater than 1');
        Test.stopTest();

    }

    @isTest
    static void createInvoiceFromOppUpdateTest(){

        List<Account> accList = TestDataFactory.createAcc(1);
        insert accList;

        Opportunity testOpp = TestDataFactory.createOpp(accList[0]);
        insert testOpp;

        List<Invoice__c> resultList = [SELECT Id FROM Invoice__c LIMIT 2];
        // No invoice should be created as StageNam is NOT 'Closed Won';
        Test.startTest();
        Assert.areEqual(0, resultList.size(), 'Result List size is not 0');

        testOpp.StageName = 'Closed Won';
        update testOpp;

        List<Invoice__c> resultInvList = [SELECT Id FROM Invoice__c LIMIT 10];
        // Only 1 Invoice should be created on update
        Assert.areEqual(1, resultInvList.size(), 'Result List size is not 1');

        testOpp.Amount = 20000;
        update testOpp;

        List<Invoice__c> resultInvListAfterUpdate = [SELECT Id FROM Invoice__c LIMIT 10];
        // Only 1 Invoice should be created on update
        Assert.areEqual(1, resultInvListAfterUpdate.size(), 'Result List size is not 1');

        Test.stopTest();

    }
}