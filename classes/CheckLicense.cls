public with sharing class CheckLicense {
    private Id userId;
    private copado.GlobalAPI.UserLicense userLicense;

    // CTOR

    public CheckLicense(Id userId) {
        this.userId = userId;
        this.userLicense = getUserLicense(userId);
    }

    // PUBLIC

    public Boolean has(String license) {
        switch on license {
            when 'Compliance Hub' {
                return userLicense.isCCHenabled;
            }
            when 'Copado User' {
                return userLicense.isCCMenabled;
            }
            when 'Copado Admin' {
                return userLicense.isCopadoEnabled;
            }
            when 'Selenium Testing' {
                return userLicense.isCSTenabled;
            }
            when else {
                return false;
            }
        }
    }

    // PRIVATE

    private copado.GlobalAPI.UserLicense getUserLicense(Id userId) {
        copado.GlobalAPI.UserLicense userLicense = new copado.GlobalAPI.UserLicense();

        for (copado.GlobalAPI.UserLicense ul : new copado.GlobalAPI().listCopadoLicenses()) {
            if (ul.userId == userId) {
                userLicense = ul;
            }
        }

        return userLicense;
    }
}