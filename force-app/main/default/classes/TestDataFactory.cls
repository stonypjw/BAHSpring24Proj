@isTest
public class TestDataFactory {
    public static Account createSingleAcc() {
        Account acc = new Account();
            acc.name = 'Test Account' + System.Today();
        return acc;
    }

    public static List<Account> createAcc(Integer num) {
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < num; i++){
            Account acc = new Account();
            acc.name = 'Test Account' + i;
            accList.add(acc);
        }
        return accList;
    }

    public static Opportunity createOpp(Account acc) {
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opp';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = System.Today() + 30;
        testOpp.Type = 'New Customer';
        testOpp.Amount = 112334.31;
        testOpp.AccountId = acc.Id;

        return testOpp;
    }

    public static Opportunity createOppWithParams(Account acc, String name, String stageName, Date closeDate, String type, Decimal amt) {
        Opportunity testOpp = new Opportunity();
        testOpp.Name = name;
        testOpp.StageName = stageName;
        testOpp.CloseDate = closeDate;
        testOpp.Type = type;
        testOpp.Amount = amt;
        testOpp.AccountId = acc.Id;

        return testOpp;
    }

    public static Account createSingleAccountWithOpp(){
        Account a = createSingleAcc();
        insert a;

        Opportunity o = createOpp(a);
        insert o;

        return a;
    }

    // Test Data for Recruiting App

    public static User createUser(Boolean isHiringManager){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'GenWatt Recruiting'];
        String random = generateRandomString(6);
        User u = new User();
        u.LastName = 'Tester';
        u.Alias = 'TesterUser';
        u.Email = 'TesterUser' + random + '@yopmail.com';
        u.Username = u.Email;
        u.CommunityNickname = 'TesterUser';
        u.ProfileId  = p.Id;
        u.IsActive = true;
        u.TimeZoneSidKey='America/New_York';
        u.LanguageLocaleKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.isHiringManager__c = isHiringManager;
        return u;
    }

    public static List<Position__c> createPositions(Integer num, User hiringManager, List<String> status){
        List<Position__c> posList = new List<Position__c>();
        if(status.size() != num){
            for(Integer i = (num-status.size()); i <= num; i++){
                status.add('New');
            }
        }

        for(Integer i = 0; i < num; i++){
            Position__c pos = new Position__c();
            pos.Description__c = 'A new exciting test position!';
            pos.Due_Date__c = System.TODAY() + 91;
            pos.Hiring_Manager__c = hiringManager.Id;
            pos.Name = 'Head Test User';
            pos.Salary__c = 95000;
            pos.Status__c = status[i];
            posList.add(pos);
        }

        return posList;
    }

    public static List<Contact> createCandidates(Integer num){
        List<Contact> candidateList = new List<Contact>();

        RecordType recrdType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Candidates'];
        Account acc = createSingleAcc();
        insert acc;

        for(Integer i = 0; i < num; i++){
            Contact c = new Contact();
            c.RecordType = recrdType;
            c.FirstName ='Candidate';
            c.LastName = 'Tester';
            c.AccountId = acc.Id;
            String random = generateRandomString(6);
            c.Email = 'Candidatetester' + random + '@yopmail.com';
            c.Phone = '123-456-7890';
            candidateList.add(c);
        }

        return candidateList;
    }

    public static List<Application__c> createApplications(Integer num, List<Contact> candidates, List<Position__c> positions){
        List<Application__c> appList = new List<Application__c>();

        for(Integer i = 0; i < num; i++){
            Application__c app = new Application__c();
            app.Name = 'Test App 1';
            app.Candidate__c = candidates[i].Id;
            app.Position__c = positions[i].Id;
            appList.add(app);
        }

        return appList;

    }

    public static List<Interviewer__c> createInterviewers(List<Application__c> appList, List<User> uList, List<Position__c> posList){
        List<Interviewer__c> intList = new List<Interviewer__c>();
        // Check that Application List is smaller or equal to User List

        for(Integer i = 0; i < appList.size(); i++){
            Interviewer__c intv = new Interviewer__c();
            if(uList[i].Id == NULL){
                intv.Interviewer__c = UserInfo.getUserId();
            } else {
                intv.Interviewer__c = uList[i].Id;
            }
            intv.Name = 'Test Interviewer ' + System.TODAY();
            intv.Position__c = posList[i].Id;
            intList.add(intv);
        }
        return intList;
    }

    public static List<Review__c> createReviews(List<Application__c> appList, List<Interviewer__c> intList){
        List<Review__c> rewList = new List<Review__c>();

        for(Integer i = 0; i <= appList.size(); i++){
            Review__c rev = new Review__c();
            rev.Application__c = appList[i].Id;
            rev.Interviewer__c = intList[i].Id;
            rev.Name = 'Test Review ' + System.TODAY();
            rewList.add(rev);
        }

        return rewList;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

}