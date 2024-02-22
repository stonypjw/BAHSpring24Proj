@isTest
public class recruitingDataFactory {

/*
Method to creste one or more positions .... return as a list
Status options - New, Open, Closed - create based on passed parameter
OPen Positions must have a Description
??What about hiring manager??
*/
//Scenario Setup Methods
public static void createSimpleInterviewScenario(String type){
    if(type=='Single'){
        List<Position__c> newPos = createPositions('Open',1);
        insert newPos;

        List<Application__c> newApps = createApplications(1,newPos);
        insert newApps;       
    }
    else if(type=='Bulk'){
        List<Position__c> newPos = createPositions('Open',201);
        insert newPos;

        List<Application__c> newApps = createApplications(1,newPos);
        insert newApps;      
    }
}

//TODO? Create method to return appliocable user based on requested persona

//Builder Methods
public static List<Position__c> createPositions(String status, Integer createNum){
    List<Position__c> newPositions = new List<Position__c>();  
    Set<String> validStatus = new Set<String>{'New','Open','Closed'};
    if(validStatus.contains(status)){
    //Retrieving user record ID to use for hiring manager
    User hMan = [SELECT ID FROM User WHERE Profile.Name='System Administrator' LIMIT 1];
    for(Integer i=0; i < createNum; i++){
        Position__c newPosition = new Position__c();
            newPosition.Name = 'Test Position #'+String.valueOf(i);
            newPosition.Hiring_Manager__c = hMan.Id;
            newPosition.Description__c = 'Description of position';
            newPosition.Due_Date__c = Date.Today()+90;
            newPosition.Status__c = status;
        newPositions.add(newPosition);
    }
}
    else {
        System.Debug('Invalid status was passed to createPositions method');
    }

    return newPositions;
}
/*
Method to create multiple applications for a position - return as a list
Will need to create contacts for each application and place them under an Account umbrella
For now, all applciations will be in the Applied status
*/
public static List<Application__c> createApplications(Integer createNum, List<Position__c> positions){
    //Assumes that positions have already been inserted
    //Create same number of contacts as createNum and then link them to all positions
    Account umbrellaAccount = new Account(Name='Umbrella Account');
    insert umbrellaAccount; 

    //Need to get correct RecordType Id for Candidates
    RecordType canRT = [SELECT ID FROM RecordType WHERE Name = 'Candidates' LIMIT 1];
    
   
    //Create contacts (candidates) linked to umbrella account and use Candidate recordtype
    List<Contact> newCan = new List<Contact>();
    for(Integer i=0; i < createNum; i++){
        Contact newContact = new Contact();
            newContact.FirstName = 'Test';
            newContact.LastName = 'Candidate#'+String.valueOf(i);
            newContact.AccountId = umbrellaAccount.Id;
            newContact.RecordTypeId = canRT.Id;
        newCan.add(newContact);
    }
    insert newCan;

    List<Application__c> newApps = new List<Application__c>();
    for(Position__c p : positions){
        for(Contact c : newCan){
            Application__c newApp = new Application__c();
                newApp.Name = 'New App';
                newApp.Candidate__c = c.Id;
                newApp.Position__c = p.Id;
                newApp.Status__c = 'Applied';
            newApps.add(newApp);
        }
    }

    return newApps;
}

/*
Method to create interviewers linked to the provided position
*/
public static Interviewer__c createInterviewer(Id positionId, Id userId){
    Interviewer__c newInt = new Interviewer__c();
        newInt.Name = 'New Test Interviewer';
        newInt.Interviewer__c = userId;
        newInt.Position__c = positionId;
    return newInt;
}

/*
Method to create or update reviews linked to the provided position
This for scenarios after interviewing stage has been completed
*/

}