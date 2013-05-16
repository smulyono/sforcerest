/*
 * Web services to query different resources
 * /<version>/sforcerest/<resources>/
 *
 * Unit Test : unit test class
 * @author : Sanny Mulyono <smulyono@me.com>
 */
@RestResource(urlmapping='/v.1/sforcerest/*')
global with sharing class SForceRest {
    public SForceRest() {}

    private static List<String> parseRestUri(String rawuri){
        List<String> retval = new List<String>();
        // remove any leading slash
        String cleanseme = rawUri.replaceFirst('^/*', '');
        for (String token : cleanseme.split('/',0)){
             if (!token.isWhiteSpace()){
                  retval.add(token);
             }
        }
        return retval;
    }

    private static String constructSOQL(Set<String> fieldnames){
        String retval = 'SELECT id';
        for (String key : fieldnames){
            if (!key.equalsIgnoreCase('id')){
                retval += ',' + key;
            }
        }
        return retval;
    }

    // Construct the SOQL needed for all GET request
    // @return String
    //
    private static String getActionSOQL(String resource){
        Set<String> fieldsets = new Set<String>();
        String soqlquery = '';
        if (resource.equalsIgnoreCase('contact')){
            Schema.DescribeSObjectResult dsor = Contact.SobjectType.getDescribe();
            Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
            fieldsets = objectFields.keySet();
            soqlquery = constructSOQL(fieldsets);
            // give the SOBJECT name to query
            soqlquery += ' FROM Contact';
        } else
        if (resource.equalsIgnoreCase('account')){
            Schema.DescribeSObjectResult dsor = Account.SobjectType.getDescribe();
            Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
            fieldsets = objectFields.keySet();
            soqlquery = constructSOQL(fieldsets);
            // also return the Contact ==
            dsor = Contact.SobjectType.getDescribe();
            objectFields = dsor.fields.getMap();
            fieldsets = objectFields.keySet();
            String subsoqlquery = constructSOQL(fieldsets);
            soqlquery += ',(' + subsoqlquery;
            soqlquery += ' FROM Contacts)';

            // give the SOBJECT name to query
            soqlquery += ' FROM Account';
        }
        return soqlquery;
    }

    // Action when get request is received
    // @return List<SObject>
    private static List<SObject> getAction(String resource){
        Set<String> fieldsets = new Set<String>();
        String soqlquery = getActionSOQL(resource);
        if (!soqlquery.equalsIgnoreCase('')) {
            return Database.query(soqlquery);
        }
        return new List<SObject>();
    }

    private static List<SOBject> putAction(String resource, Restrequest req) {
        return null;
    }

    @HttpGet
    global static List<SObject> doGet(){
       // Rest context
       Restrequest req = RestContext.request;
       // parse the resources
       List<String> resources = SForceRest.parseRestUri(req.requestURI);
       if (resources.size() > 2){
            return SForceRest.getAction(resources.get(2));
            // return SForceRest.getActionSOQL(resources.get(2));
       }
       // return '';
       return new List<SObject>();
    }

    // WIP -- not implemented yet
    @HttpPut
    global static List<SObject> doPut(){
       // Rest context
       Restrequest req = RestContext.request;
       // parse the resources
       List<String> resources = SForceRest.parseRestUri(req.requestURI);
       if (resources.size() > 2){
            return SForceRest.putAction(resources.get(2), req);
       }
       // return new List<SObject>();
       return null;
    }
}