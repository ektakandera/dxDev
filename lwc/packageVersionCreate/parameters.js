export const parameters = [
    {
        label: "Package Version Name",
        type: "text",
        name: "versionname",
        value: "",
        help: "The name of the package version to be created."
    },
    {
        label: "Version Number",
        type: "text",
        name: "versionnumber",
        value: "",
        help: "The version number of the package version to be created."
    },
    {
        label: "Path",
        type: "text",
        name: "path",
        value: "",
        help: "The path to the directory that contains the contents of the package."
    },
    {
        label: "Branch Name",
        type: "text",
        name: "branch",
        value: "",
        help: "Name of the branch in your source control system that the package version is based on."
    },
    { label: "Tag", type: "text", name: "tag", value: "", help: "The package version’s tag." },
    {
        label: "Definition File",
        type: "text",
        name: "definitionfile",
        value: "",
        help: "The path to a definition file similar to scratch org definition file that contains the list of features and org preferences that the metadata of the package version depends on."
    },
    {
        label: "Code Coverage",
        type: "checkbox",
        name: "codecoverage",
        value: false,
        help: "Calculate and store the code coverage percentage by running the Apex tests included in this package version."
    },
    {
        label: "Installation Key Bypass",
        type: "checkbox",
        name: "installationkeybypass",
        value: false,
        help: "Bypasses the installation key requirement. If you bypass this requirement, anyone can install your package."
    },
    {
        label: "Installation key",
        type: "text",
        name: "installationkey",
        value: "",
        help: "Installation key for creating the key-protected package."
    },
    {
        label: "Version Description",
        type: "text",
        name: "versiondescription",
        value: "",
        help: "The description of the package version to be created."
    },

    {
        label: "Release Notes URL",
        type: "url",
        name: "releasenotesurl",
        value: "",
        help: "The release notes URL. This link is displayed in the package installation UI to provide release notes for this package version to subscribers."
    },
    {
        label: "Post Install URL",
        type: "url",
        name: "postinstallurl",
        value: "",
        help: "The post-install instructions URL. The contents of the post-installation instructions URL are displayed in the UI after installation of the package version."
    },
    {
        label: "Post Install Script",
        type: "text",
        name: "postinstallscript",
        value: "",
        help: "The post-install script name. The post-install script is an Apex class within this package that is run in the installing org after installations or upgrades of this package version."
    },
    {
        label: "Uninstall Script",
        type: "text",
        name: "uninstallscript",
        value: "",
        help: "The uninstall script name. The uninstall script is an Apex class within this package that is run in the installing org after uninstallations of this package."
    },
    {
        label: "Skip Validation",
        type: "checkbox",
        name: "skipvalidation",
        value: false,
        help: "Skips validation of dependencies, package ancestors, and metadata during package version creation."
    }
];