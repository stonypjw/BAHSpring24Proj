@isTest
private class ApplicationHandlerTest {
    
    @isTest
    private static void testApplicationUpdate_Positive(){
      //Need an application on a position set to Interviewing
      recruitingDataFactory.createSimpleInterviewScenario('Single');
      
       //Keep in mind that there should be an interviewer records automatically created for the Hiring Manager

      Test.startTest();
      Application__c currentApp = [SELECT Id, Position__c, Status__c FROM Application__c LIMIT 1];
      currentApp.Status__c = 'Interviewing';
      update currentApp;
      Test.stopTest();

      //Check to see that 2 review records have been created for the application
      List<Review__c> newRev = [SELECT ID, Application__c, Interviewer__c FROM Review__c];
      System.assertEquals(1, newRev.size(), 'Incorrect number of review records created');

    }
    @isTest
    private static void testApplicationUpdate_Negative(){
       //Need an application on a position set to Interviewing
       recruitingDataFactory.createSimpleInterviewScenario('Single');
 
          //Keep in mind that there should be an interviewer records automatically created for the Hiring Manager
 
       Test.startTest();
       Application__c currentApp = [SELECT Id, Position__c, Status__c FROM Application__c LIMIT 1];
       currentApp.Status__c = 'Rejected';
       update currentApp;
       Test.stopTest();
 
       //Check to see that 2 review records have been created for the application
       List<Review__c> newRev = [SELECT ID, Application__c, Interviewer__c FROM Review__c];
       System.assertEquals(0, newRev.size(), 'Incorrect number of review records created');
 
    }
    @isTest
    private static void testApplicationUpdateBulk_Positive(){
      //Need an application on a position set to Interviewing
      recruitingDataFactory.createSimpleInterviewScenario('Bulk');


       //Keep in mind that there should be an interviewer records automatically created for the Hiring Manager

      Test.startTest();
      List<Application__c> currentApps = [SELECT Id, Position__c, Status__c FROM Application__c];
      for (Application__c app : currentApps){
        app.Status__c = 'Interviewing';
      }
            update currentApps;
      Test.stopTest();

      //Check to see that 1 review record for each applciation have been created Total of 201
      List<Review__c> newRev = [SELECT ID, Application__c, Interviewer__c FROM Review__c];
      System.assertEquals(201, newRev.size(), 'Incorrect number of review records created');
    }

}