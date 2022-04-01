@IsTest
private class CheckLicenseTest {

    @TestSetup
    private static void makeData() {
        User u = TestDataFactory.createUser('Standard User');
        insert u;

        TestDataFactory.assignPermissionSet(u, new Set<String>{ 'Copado_User' });
    }

    @IsTest
    private static void userWithLicense() {
        User u = getRunAsUser();
        System.runAs(u) {
            // Setup

            TestDataFactory.assignLicense(u.Id, false, false, true, false, false);

            // Exercise

            Boolean hasLicense = new CheckLicense(u.Id).has('Copado User');

            // Verify

            System.assertEquals(true, hasLicense, 'User should have a license.');
        }
    }

    @IsTest
    private static void userWithoutLicense() {
        User u = getRunAsUser();
        System.runAs(u) {
            // Setup

            TestDataFactory.assignLicense(u.Id, false, false, false, false, false);

            // Exercise

            Boolean hasLicense = new CheckLicense(u.Id).has('Copado User');

            // Verify

            System.assertEquals(false, hasLicense, 'User should not have a license.');
        }
    }

    // HELPER

    private static User getRunAsUser() {
        return [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'Standard User' AND UserName LIKE '%testcmcsf@copado.com%'
            LIMIT 1
        ];
    }
}