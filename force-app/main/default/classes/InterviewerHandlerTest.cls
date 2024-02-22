@isTest
private class InterviewerHandlerTest {

    // Make a test with no Application


    // Make a test with no position


        /*As a recruiter, when I attach an interviewer to a specific position, I need review records to be generated for each applicant in the interviewing stage so that the designated interviewer can see who they need to meet with. 
      Trigger on Interviewer object*/
      @isTest
      private static void testNewInterviewerInsert_Positive(){
        //Need an application on a position set to Interviewing
        recruitingDataFactory.createSimpleInterviewScenario('Single');
        Application__c currentApp = [SELECT Id, Position__c, Status__c FROM Application__c LIMIT 1];
        currentApp.Status__c = 'Interviewing';
        update currentApp;

        User newIntUser = [SELECT ID FROM User WHERE Profile.Name='Standard Platform User' LIMIT 1];

        Test.startTest();
        //Add an interviewer
        Interviewer__c newInt = recruitingDataFactory.createInterviewer(currentApp.Position__c, newIntUser.Id);
        insert newInt;
        Test.stopTest();

        //Check to see that a review record has been created for the application
        List<Review__c> newRev = [SELECT ID, Application__c, Interviewer__c FROM Review__c];
        System.assertEquals(1, newRev.size(), 'Incorrect number of review records created');
        for(Review__c r: newRev){
            System.assertEquals(currentApp.Id, r.Application__c, 'Review record created but not linked to Application');
            System.assertEquals(newInt.Id, r.Interviewer__c, 'Review record created but not linked to Application');
        }

      }
      @isTest
      private static void testNewInterviewerInsert_Negative(){
         //Need an application on a position set to Interviewing
         recruitingDataFactory.createSimpleInterviewScenario('Single');
         Application__c currentApp = [SELECT Id, Position__c, Status__c FROM Application__c LIMIT 1];
 
         User newIntUser = [SELECT ID FROM User WHERE Profile.Name='Standard Platform User' LIMIT 1];
 
         Test.startTest();
         //Add an interviewer
         Interviewer__c newInt = recruitingDataFactory.createInterviewer(currentApp.Position__c, newIntUser.Id);
         insert newInt;
         Test.stopTest();
 
         //Check to see that a review record has been created for the application
         List<Review__c> newRev = [SELECT ID, Application__c, Interviewer__c FROM Review__c];
         System.assertEquals(0, newRev.size(), 'Incorrect number of review records created');
      }
      @isTest
      private static void testNewInterviewerInsertBulk_Positive(){
        //Need an application on a position set to Interviewing
        List<Position__c> newPos = recruitingDataFactory.createPositions('Open',1);
        insert newPos;
        List<Application__c> newApps = recruitingDataFactory.createApplications(201,newPos);
        insert newApps;
        for (Application__c a : newApps){
            a.Status__c = 'Interviewing';
        }
        update newApps;
        User newIntUser = [SELECT ID FROM User WHERE Profile.Name='Standard Platform User' LIMIT 1];

        Test.startTest();
        //Add an interviewer
        Interviewer__c newInt = recruitingDataFactory.createInterviewer(newPos[0].Id, newIntUser.Id);
        insert newInt;
        Test.stopTest();

        //Check to see that a review record has been created for the application
        List<Review__c> newRev = [SELECT ID, Application__c, Interviewer__c FROM Review__c];
        System.assertEquals(201, newRev.size(), 'Incorrect number of review records created');
        Set<Id> appIds = new Set<Id>();
        for(Review__c r: newRev){
            appIds.add(r.Application__c);
            System.assertEquals(newInt.Id, r.Interviewer__c, 'Review record created but not linked to Application');
        }
        System.assertEquals(201, appids.size(), 'Incomplete linking of review records to applications');
      }

    
}