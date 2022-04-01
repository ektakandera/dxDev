@IsTest
public with sharing class TestUtilities {
    public static void setup() {
        User runAsUser = createUser();
        assignPermissionSet(runAsUser.Id);
        System.runAs(runAsUser) {
            assignLicense(runAsUser.Id);
        }
    }

    public static User createUser() {
        User runAsUser = new User(
            LastName = 'UserLastName',
            Username = 'username@myemail.com',
            Email = 'username@myemail.com',
            Alias = 'MyAlias',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = getProfile('Standard User').Id,
            LanguageLocaleKey = 'en_US'
        );
        insert runAsUser;
        return runAsUser;
    }

    private static Profile getProfile(String name) {
        return [SELECT Id, Name FROM Profile WHERE Name = :name];
    }

    public static User getRunAsUser() {
        List<User> runAsUsers = [SELECT Id FROM User WHERE Username = 'username@myemail.com'];
        return runAsUsers[0];
    }

    public static void assignLicense(Id userId) {
        copado.GlobalAPI copadoGlobalAPI = new copado.GlobalAPI();
        copado.GlobalAPI.UserLicense userLicense = new copado.GlobalAPI.UserLicense();
        userLicense.isCCMEnabled = true;
        userLicense.isCopadoEnabled = true;
        userLicense.userId = userId;
        copadoGlobalAPI.upsertCopadoLicense(userLicense);
    }

    public static void assignPermissionSet(Id userId) {
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();

        Set<String> permissions = new Set<String>{
            'Copado_User',
            'Copado_Functions',
            'Copado_Job_Engine',
            'CMC_SFDX_Admin'
        };
        
        for (PermissionSet permission : [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Name IN :permissions
        ]) {
            assignments.add(
                new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permission.Id)
            );
        }
        insert assignments;
    }
}