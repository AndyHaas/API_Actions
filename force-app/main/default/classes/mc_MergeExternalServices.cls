public with sharing class mc_MergeExternalServices {
    @AuraEnabled
    public static List<mc_MergeExternalServices_Definition> getExternalServices() {
        // Get the URL for current org
        // SELECT MasterLabel, NamedCredential, Schema, SchemaType, Status FROM ExternalServiceRegistration
        String orgUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v57.0/tooling/query/?q=SELECT+Id,+MasterLabel,+NamedCredential,+Schema,+SchemaType,+Status+FROM+ExternalServiceRegistration';

        // Create the request
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setEndpoint(orgUrl);
        req.setMethod('GET');

        // Send the request
        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('res: ' + JSON.serialize(res.getBody()));

        // Check the response
        if (res.getStatusCode() != 200) {
            System.debug('Error retrieving External Service Registration');
            System.debug('statusCode: ' + res.getStatusCode());
            throw new AuraHandledException('Error retrieving External Service Registration');
        }

        // Parse the response
        mc_ToolingResponse results = (mc_ToolingResponse) JSON.deserialize(res.getBody(), mc_ToolingResponse.class);

        // Return the results
        System.debug('results: ' + JSON.serialize(results));
        System.debug('results.records: ' + JSON.serialize(results.records));
        System.debug('results.records[0]: ' + JSON.serialize(results.records[0]));
        System.debug('results.records[0].MasterLabel: ' + JSON.serialize(results.records[0].MasterLabel));

        List<mc_MergeExternalServices_Definition> returnResults = new List<mc_MergeExternalServices_Definition>();
        returnResults = results.records;
        
        return returnResults;

    }

    @AuraEnabled
    public static Boolean mergeExternalServices(String convertFrom, String convertTo) {
        // Create the services
        mc_MergeExternalServices_Definition convertFromService = new mc_MergeExternalServices_Definition();
        mc_MergeExternalServices_Definition convertToService = new mc_MergeExternalServices_Definition();

        // Convert the convertFrom and convertTo to mc_MergeExternalServices_Definition
        convertFromService = (mc_MergeExternalServices_Definition) JSON.deserialize(convertFrom, mc_MergeExternalServices_Definition.class);
        convertToService = (mc_MergeExternalServices_Definition) JSON.deserialize(convertTo, mc_MergeExternalServices_Definition.class);

        // Convert the Schema to a String
        String convertFromSchemaString = convertFromService.Schema;
        String convertToSchemaString = convertToService.Schema;
        System.debug('convertFromSchemaString: ' + convertFromSchemaString);
        System.debug('convertToSchemaString: ' + convertToSchemaString);
        
        // Within the convertFromSchemaString find the paths key
        Integer convertFromPathsIndex = convertFromSchemaString.indexOf('paths');
        Integer convertFromPathsEndIndex = convertFromSchemaString.indexOf('}', convertFromPathsIndex);
        String convertFromPathsString = convertFromSchemaString.substring(convertFromPathsIndex, convertFromPathsEndIndex + 1);
        System.debug('convertFromPathsString: ' + convertFromPathsString);

        // Within the convertToSchemaString find the paths key and the end of the paths key
        Integer convertToPathsIndex = convertToSchemaString.indexOf('paths');
        Integer convertToPathsEndIndex = convertToSchemaString.indexOf('}', convertToPathsIndex);
        String convertToPathsString = convertToSchemaString.substring(convertToPathsIndex, convertToPathsEndIndex + 1);
        System.debug('convertToPathsString: ' + convertToPathsString);
        
        // Remove } from the end of convertToPathsString
        String convertToSchemaStringUpdated = convertToSchemaString.substring(0, convertToPathsEndIndex);
        System.debug('convertToSchemaStringUpdated: ' + convertToSchemaStringUpdated);

        // Add comma to the end of convertToSchemaStringUpdated
        convertToSchemaStringUpdated = convertToSchemaStringUpdated + ',';
        System.debug('convertToSchemaStringUpdated: ' + convertToSchemaStringUpdated);

        System.debug('convertFromPathsString: ' + convertFromPathsString);
        // Remove paths key from the convertFromPathsString and remove the first { from the string and remove the last } from the string
        convertFromPathsString = convertFromPathsString.replace('paths', '');
        System.debug('convertFromPathsString 1: ' + convertFromPathsString);

        // Find the first { and remove it
        Integer convertFromPathsFirstIndex = convertFromPathsString.indexOf('{');
        convertFromPathsString = convertFromPathsString.substring(convertFromPathsFirstIndex + 1, convertFromPathsString.length());
        System.debug('convertFromPathsString 2: ' + convertFromPathsString);

        // Find the last } and remove it
        // Integer convertFromPathsLastIndex = convertFromPathsString.lastIndexOf('}');
        // convertFromPathsString = convertFromPathsString.substring(0, convertFromPathsLastIndex);
        // System.debug('convertFromPathsString 3: ' + convertFromPathsString);

        // Find the first : and remove it
        // Integer convertFromPathsFirstColonIndex = convertFromPathsString.indexOf(':');
        // convertFromPathsString = convertFromPathsString.substring(convertFromPathsFirstColonIndex + 1, convertFromPathsString.length());
        // System.debug('convertFromPathsString 4: ' + convertFromPathsString);
    

        // Add convertFromPathsString to the end of convertToSchemaStringUpdated
        convertToSchemaStringUpdated = convertToSchemaStringUpdated + convertFromPathsString;
        System.debug('convertToSchemaStringUpdated 0: ' + convertToSchemaStringUpdated);

        return true;

    }
}