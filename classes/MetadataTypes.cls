public with sharing class MetadataTypes {
    private static final String METADATA_API = 'MetadataAPI';
    private static final String TOOLING_API = 'ToolingAPI';
    private static final Map<String, Set<String>> METADATA_TYPES_BY_API = new Map<String, Set<String>>{
        METADATA_API => new Set<String>{
            'AccountForecastSettings',
            'AccountRelationshipShareRule',
            'AcctMgrTargetSettings',
            'ActionLinkGroupTemplate',
            'AdvAccountForecastSet',
            'AdvAcctForecastDimSource',
            'AdvAcctForecastPeriodGroup',
            'AIApplication',
            'AIApplicationConfig',
            'AnalyticSnapshot',
            'AnimationRule',
            'ApexEmailNotifications',
            'ApexTestSuite',
            'AppMenu',
            'ApprovalProcess',
            'ArchiveSettings',
            'AssignmentRules',
            'Audience',
            'AuthProvider',
            'AutoResponseRules',
            'BatchCalcJobDefinition',
            'BatchProcessJobDefinition',
            'BlacklistedConsumer',
            'BlockchainSettings',
            'BranchManagementSettings',
            'CallCenter',
            'CallCoachingMediaProvider',
            'CanvasMetadata',
            'CareBenefitVerifySettings',
            'ChannelLayout',
            'ChatterExtension',
            'CMSConnectSource',
            'CommerceSettings',
            'Community',
            'CommunityTemplateDefinition',
            'CommunityThemeDefinition',
            'ConnectedApp',
            'ContentAsset',
            'CorsWhitelistOrigin',
            'CspTrustedSite',
            'CustomApplicationComponent',
            'CustomerDataPlatformSettings',
            'CustomFeedFilter',
            'CustomHelpMenuSection',
            'CustomIndex',
            'CustomMetadata',
            'CustomNotificationType',
            'CustomObjectTranslation',
            'CustomPageWebLink',
            'CustomPermission',
            'CustomSite',
            'CustomTab',
            'CustomValue',
            'Dashboard',
            'DashboardFolder',
            'DataCategoryGroup',
            'DecisionTable',
            'DecisionTableDatasetLink',
            'DelegateGroup',
            'DiscoverySettings',
            'Document',
            'DocumentChecklistSettings',
            'DocumentFolder',
            'DocumentType',
            'DuplicateRule',
            'EclairGeoData',
            'EinsteinAssistantSettings',
            'EinsteinDocumentCaptureSettings',
            'EmailFolder',
            'EmailServicesFunction',
            'EmailTemplateFolder',
            'EmbeddedServiceFlowConfig',
            'EmployeeFieldAccessSettings',
            'EntitlementProcess',
            'EntitlementTemplate',
            'EntityImplements',
            'EscalationRules',
            'EssentialsSettings',
            'ExperienceBundle',
            'FeatureParameterBoolean',
            'FeatureParameterDate',
            'FeatureParameterInteger',
            'FlowCategory',
            'FlowCategory',
            'FormulaSettings',
            'GatewayProviderPaymentMethodType',
            'GlobalValueSetTranslation',
            'GoogleAppsSettings',
            'Index',
            'IndustriesManufacturingSettings',
            'InstalledPackage',
            'Letterhead',
            'LightningBolt',
            'LightningExperienceTheme',
            'LightningMessageChannel',
            'LightningOnboardingConfig',
            'ListView',
            'ManagedTopics',
            'MilestoneType',
            'MLDataDefinition',
            'MLPredictionDefinition',
            'MLRecommendationDefinition',
            'MobileApplicationDetail',
            'MutingPermissionSet',
            'MyDomainDiscoverableLogin',
            'NavigationMenu',
            'Network',
            'NetworkBranding',
            'NotificationTypeConfig',
            'OauthCustomScope',
            'ObjectHierarchyRelationship',
            'PaymentGatewayProvider',
            'PicklistValue',
            'PlatformCachePartition',
            'PresenceDeclineReason',
            'PresenceUserConfig',
            'ProfilePasswordPolicy',
            'ProfileSessionSetting',
            'Profile',
            'Prompt',
            'Queue',
            'QueueRoutingConfig',
            'RecordType',
            'RedirectWhitelistUrl',
            'RemoteSiteSetting',
            'Report',
            'ReportFolder',
            'ReportType',
            'RestrictionRule',
            'Role',
            'SamlSsoConfig',
            'ServiceChannel',
            'ServicePresenceStatus',
            'Settings',
            'SharingCriteriaRule',
            'SharingGuestRule',
            'SharingOwnerRule',
            'SharingReason',
            'SharingRules',
            'SharingSet',
            'SharingTerritoryRule',
            'SiteDotCom',
            'SlackApp',
            'StandardValue',
            'StandardValueSet',
            'StandardValueSetTranslation',
            'SynonymDictionary',
            'TopicsForObjects',
            'Translations',
            'UserProvisioningConfig',
            'ViewDefinition',
            'Workflow',
            'WorkflowFlowAction',
            'WorkflowKnowledgePublish',
            'WorkflowSend',
            'WorkflowTask'
        },
        TOOLING_API => new Set<String>{
            'ApexClass',
            'ApexComponent',
            'ApexPage',
            'ApexTrigger',
            'AuraDefinitionBundle',
            'BrandingSet',
            'BriefcaseDefinition',
            'BusinessProcess',
            'BusinessProcessGroup',
            'Certificate',
            'CleanDataService',
            'CompactLayout',
            'CustomApplication',
            'CustomField',
            'CustomLabel',
            'CustomObject',
            'EmailTemplate',
            'EmbeddedServiceBranding',
            'EmbeddedServiceConfig',
            'EmbeddedServiceLiveAgent',
            'EmbeddedServiceMenuSettings',
            'ExternalDataSource',
            'ExternalServiceRegistration',
            'ExternalServicesSettings',
            'FieldRestrictionRule',
            'FieldSet',
            'FlexiPage',
            'Flow',
            'FlowDefinition',
            'GlobalValueSet',
            'Group',
            'HomePageComponent',
            'HomePageLayout',
            'InboundNetworkConnection',
            'IPAddressRange',
            'KeywordList',
            'Layout',
            'LightningComponentBundle',
            'ManagedContentType',
            'MatchingRules',
            'ModerationRule',
            'NamedCredential',
            'OutboundNetworkConnection',
            'PathAssistant',
            'PermissionSet',
            'PermissionSetGroup',
            'PlatformEventChannel',
            'PlatformEventChannelMember',
            'PlatformEventSubscriberConfig',
            'QuickAction',
            'RecommendationStrategy',
            'RecordActionDeployment',
            'StaticResource',
            'TimeSheetTemplate',
            'TransactionSecurityPolicy',
            'UserCriteria',
            'ValidationRule',
            'WebLink',
            'WorkflowAlert',
            'WorkflowFieldUpdate',
            'WorkflowOutboundMessage',
            'WorkflowRule',
            'WorkSkillRouting'
        }
    };

    public static List<String> toolingApiTypes() {
        List<String> result = new List<String>(METADATA_TYPES_BY_API.get(TOOLING_API));
        result.sort();
        return result;
    }

    public static List<String> metadataApiTypes() {
        List<String> result = new List<String>(METADATA_TYPES_BY_API.get(METADATA_API));
        result.sort();
        return result;
    }

    public static List<String> supportedMetadataTypes() {
        List<String> result = new List<String>();
        result.addAll(metadataApiTypes());
        result.addAll(toolingApiTypes());
        result.sort();
        return result;
    }
}