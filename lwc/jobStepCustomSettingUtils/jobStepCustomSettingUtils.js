const TYPE = 'type';
const CUSTOM_SETTING = 'Custom Setting';
export const ERROR = 'Error';

export const getConfig = (customSettingName, selectedRecords) => {
    return { [TYPE]: CUSTOM_SETTING, configJson: { [customSettingName]: selectedRecords } };
};

export const onRowSelection = (currentSelectedRows, totalRecords, totalSelectedRecords) => {
    const currentSelection = currentSelectedRows.map((record) => record.Id);
    totalRecords.forEach((record) => {
        if (currentSelection.includes(record.Id) && !totalSelectedRecords.includes(record.Id)) {
            totalSelectedRecords.push(record.Id);
        } else if (!currentSelection.includes(record.Id) && totalSelectedRecords.includes(record.Id)) {
            totalSelectedRecords.splice(totalSelectedRecords.indexOf(record.Id), 1);
        }
    });
    return totalSelectedRecords;
};

export const getItemDetailsVerbiage = (selectedItems, label) => {
    return selectedItems?.length > 1 ? label.ItemsSelected : label.ItemSelected;
};

export const getAutoFormValidation = (selectedItems, label) => {
    return selectedItems?.length
        ? { isValid: true, data: null }
        : { isValid: false, data: { message: label.CustomSettingMinRecordsCriteria, variant: ERROR, title: ERROR } };
};