import { Visual } from "../../src/visual";
import powerbiVisualsApi from "powerbi-visuals-api";
import IVisualPlugin = powerbiVisualsApi.visuals.plugins.IVisualPlugin;
import VisualConstructorOptions = powerbiVisualsApi.extensibility.visual.VisualConstructorOptions;
import DialogConstructorOptions = powerbiVisualsApi.extensibility.visual.DialogConstructorOptions;
var powerbiKey: any = "powerbi";
var powerbi: any = window[powerbiKey];
var interactiveboxplotsviz2CAEF8A92DBA4E7AB2DB9F277A5BECE1: IVisualPlugin = {
    name: 'interactiveboxplotsviz2CAEF8A92DBA4E7AB2DB9F277A5BECE1',
    displayName: 'Interactive Boxplots',
    class: 'Visual',
    apiVersion: '3.8.0',
    create: (options: VisualConstructorOptions) => {
        if (Visual) {
            return new Visual(options);
        }
        throw 'Visual instance not found';
    },
    createModalDialog: (dialogId: string, options: DialogConstructorOptions, initialState: object) => {
        const dialogRegistry = globalThis.dialogRegistry;
        if (dialogId in dialogRegistry) {
            new dialogRegistry[dialogId](options, initialState);
        }
    },
    custom: true
};
if (typeof powerbi !== "undefined") {
    powerbi.visuals = powerbi.visuals || {};
    powerbi.visuals.plugins = powerbi.visuals.plugins || {};
    powerbi.visuals.plugins["interactiveboxplotsviz2CAEF8A92DBA4E7AB2DB9F277A5BECE1"] = interactiveboxplotsviz2CAEF8A92DBA4E7AB2DB9F277A5BECE1;
}
export default interactiveboxplotsviz2CAEF8A92DBA4E7AB2DB9F277A5BECE1;