import type { PluginListenerHandle, Plugin } from "@capacitor/core";

export interface AssetUploadPlugin extends Plugin {
  upload(options: {url : string, ids: Array<string>}): Promise<any>;
  addListener(eventName: 'assetUploadProgress', listenerFunc: (event: { id: string, progress: number }) => void): Promise<PluginListenerHandle> & PluginListenerHandle
}
