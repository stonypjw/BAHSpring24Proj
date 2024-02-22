global class CreditCheckRequest {

    @InvocableMethod(label='Credit Check Request'
                        description='Sends a request to Credit Check Service.')
    global static void CreditCheck(List<String> accIds){        

        // Call the Future Method to do the API Call out
        if(accIds.size() > 0){
            CallCreditCheckAPI(accIds[0]);
        }
        

    }
    
    @future(callout=true)
    public static void CallCreditCheckAPI(String accId){
        
        Account acc = [SELECT Id, Name, Owner.Email, Owner.Name, Credit_Check_Id__c FROM Account WHERE Id =: accId LIMIT 1];
        String url = 'https://steve-wasula-splx201-dev-ed.my.salesforce-sites.com/creditcheck';
        url += '?name=' + EncodingUtil.urlEncode(acc.Name, 'UTF-8');
        url += '&email=' + acc.Owner.Email;
        url += '&requestor=' + EncodingUtil.urlEncode(acc.Owner.Name, 'UTF-8');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            // Do stuff
            // System.debug(response.getBody());
        }
        /*
            String accId = '001al000000NaKfAAK';
            CreditCheckRequest.CreditCheck(accId);
            Response.getBody():
            {"attributes":
                    {"type":"Credit_Check__c",
                    "url":"/services/data/v60.0/sobjects/Credit_Check__c/a023u00001UgbbCAAR"},
                    "Company_Name__c":"United Oil & Gas Corp.",
                    "Requestor_Name__c":"Dar Wright",
                    "Requestor_Email__c":"637497@bah.com", 
                    "Name":"Dar Wright United Oil & Gas Corp.",
                    "Id":"a023u00001UgbbCAAR"
                }
        */
        ccReturn ccResponse = (ccReturn) JSON.deserialize(response.getBody(), ccReturn.class);

        acc.Credit_Check_Id__c = ccResponse.Id;
        update acc;

    }

    
    public class ccReturn{

        public String type;
        public String url;
        public String Company_Name_c;
        public String Requestor_Name_c;
        public String Requestor_Email_c;
        public String Name;
        public String Id;

    }



}