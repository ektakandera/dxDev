public class MetaDataItem {
    public String t { get; set; } // Metadata Type
	@AuraEnabled
    public String n { get; set; } // Metadata Name
	@AuraEnabled
    public Boolean r { get; set; } // Retrieve Only
	@AuraEnabled
    public Boolean s { get; set; } // Metadata Is Selected
	@AuraEnabled
	public String ns { get; set; } // Metadata Name
    public String cb { get; set; } // Created By
    public String cd { get; set; } // Created Date
    public String vk { get; set; } // Vlocity key
    @AuraEnabled 
	public String Name { get; set; }
	@AuraEnabled 
	public String NamespacePrefix { get; set; }

	public static List<MetaDataItem> parse(String json) {
		List<MetaDataItem> result = new List<MetaDataItem>();

        Map<String, Object> fieldList = (Map<String, Object>) System.JSON.deserializeUntyped(json);

        for (Object obj : (List<Object>) fieldList.get('searchRecords')) {
            Map<String, Object> data = (Map<String, Object>) obj;

            MetaDataItem item = new MetaDataItem();
            item.n = data.get('Name').toString();
            item.ns = data.get('NamespacePrefix')?.toString();

            result.add(item);
        }

        return result;

	}

    public static List<MetaDataItem> parseForFileJSON(String json) {
		return (List<MetaDataItem>) System.JSON.deserialize(json, List<MetaDataItem>.class);
	}

}