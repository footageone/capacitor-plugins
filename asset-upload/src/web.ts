import { WebPlugin } from '@capacitor/core';

import type { AssetUploadPlugin } from './definitions';

export class AssetUploadWeb extends WebPlugin implements AssetUploadPlugin {
  async upload(options: { url: string, ids: string[]  }): Promise<any> {
    return options;
  }
}
