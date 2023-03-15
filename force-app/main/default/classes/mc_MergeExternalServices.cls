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
    public static String mergeExternalServices(String convertFrom, String convertTo) {
        // Convert the JSON strings to maps
        Map<String, Object> convertFromMap = (Map<String, Object>) JSON.deserializeUntyped(convertFrom);
        Map<String, Object> convertToMap = (Map<String, Object>) JSON.deserializeUntyped(convertTo);

        System.debug('convertFromMap: ' + (convertFromMap));
        System.debug('convertToMap: ' + (convertToMap));

        System.debug('convertFromMap.get("Schema"): ' + JSON.serializePretty(convertFromMap.get('Schema')));
        System.debug('convertToMap.get("Schema"): ' + JSON.serializePretty(convertToMap.get('Schema')));

        // Get the "Id" from both maps
        String convertToId = (String) convertToMap.get('Id');
        String convertFromId = (String) convertFromMap.get('Id');

        // Get the "Schema" strings from both maps
        String convertFromSchema = (String) convertFromMap.get('Schema');
        String convertToSchema = (String) convertToMap.get('Schema');

        // Convert the "Schema" strings to maps
        Map<String, Object> convertFromSchemaMap = (Map<String, Object>) JSON.deserializeUntyped(convertFromSchema);
        Map<String, Object> convertToSchemaMap = (Map<String, Object>) JSON.deserializeUntyped(convertToSchema);

        System.debug('convertFromSchemaMap: ' + JSON.serializePretty(convertFromSchemaMap));
        System.debug('convertToSchemaMap: ' + JSON.serializePretty(convertToSchemaMap));

        // Get the "paths" objects from both maps
        Map<String, Object> convertFromPaths = (Map<String, Object>) convertFromSchemaMap.get('paths');
        Map<String, Object> convertToPaths = (Map<String, Object>) convertToSchemaMap.get('paths');

        System.debug('convertFromPaths: ' + JSON.serializePretty(convertFromPaths));
        System.debug('convertToPaths: ' + JSON.serializePretty(convertToPaths));

        // Combine the "paths" objects into a single map
        Map<String, Object> combinedPaths = new Map<String, Object>();
        combinedPaths.putAll(convertFromPaths);
        combinedPaths.putAll(convertToPaths);

        System.debug('combinedPaths: ' + JSON.serializePretty(combinedPaths));

        // Delete the "paths" object from the convertToMap
        convertToSchemaMap.remove('paths');

        // Replace the paths string in the convertToMap with the combined "paths" object
        convertToSchemaMap.put('paths', combinedPaths);

        System.debug('convertToSchemaMap UPDATED: ' + JSON.serializePretty(convertToSchemaMap));

        // Delete the "Schema" object from the convertToMap
        convertToMap.remove('Schema');

        // Put the convertToSchemaMap back into the convertToMap
        convertToMap.put('Schema', convertToSchemaMap);

        System.debug('convertToMap UPDATED: ' + JSON.serializePretty(convertToMap));

        // Serialize the combined map into a JSON string
        String combinedJson = JSON.serialize(convertToMap);

        System.debug('combinedJson: ' + combinedJson);

        // Convert combinedPaths to a string
        String combinedPathsString = JSON.serialize(convertToSchemaMap);

        //return combinedPathsString;

        // Update the External Service Registration record
        return updateExternalServices(combinedPathsString, convertToId, convertFromId);

    }

    public static String updateExternalServices(String newSchema, String externalToServiceId, String externalFromServiceId) {
        // Get the URL for current org
        // SELECT MasterLabel, NamedCredential, Schema, SchemaType, Status FROM ExternalServiceRegistration
        String orgUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v57.0/tooling/sobjects/ExternalServiceRegistration/' + externalToServiceId;

        System.debug('newSchema: ' + JSON.serializePretty(newSchema));

        // Create Body
        Map<String, Object> body = new Map<String, Object>();
        body.put('Schema', newSchema);

        // Create the request
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setEndpoint(orgUrl);
        req.setMethod('PATCH');
        req.setBody(JSON.serialize(body));
        req.setHeader('Content-Type', 'application/json');

        // Send the request
        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('res: ' + JSON.serialize(res.getBody()));

        // Check the response
        if (res.getStatusCode() != 204) {
            System.debug('Error updating ExternalServiceRegistration object. Response status: ' + res.getStatus());
            System.debug('Response body: ' + res.getBody());
            throw new AuraHandledException('Error updating External Service Registration');
        } else {
            System.debug('ExternalServiceRegistration object updated successfully.');

            // Delete the old External Service Registration record
            return deleteExternalServices(externalFromServiceId);
        }

    }

    public static String deleteExternalServices(String externalServiceId) {
        // Get the URL for current org
        // SELECT MasterLabel, NamedCredential, Schema, SchemaType, Status FROM ExternalServiceRegistration
        String orgUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v57.0/tooling/sobjects/ExternalServiceRegistration/' + externalServiceId;

        // Create the request
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setEndpoint(orgUrl);
        req.setMethod('DELETE');

        // Send the request
        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('res: ' + JSON.serialize(res.getBody()));

        // Check the response
        if (res.getStatusCode() != 204) {
            System.debug('Error deleting ExternalServiceRegistration object. Response status: ' + res.getStatus());
            System.debug('Response body: ' + res.getBody());
            throw new AuraHandledException('Error deleting External Service Registration');
        } else {
            System.debug('ExternalServiceRegistration object deleted successfully.');
            return 'Success';
        }

    }
}