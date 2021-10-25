import { registerPlugin } from '@capacitor/core';

import type { AssetUploadPlugin } from './definitions';

const AssetUpload = registerPlugin<AssetUploadPlugin>('AssetUpload', {
  web: () => import('./web').then(m => new m.AssetUploadWeb()),
});

export * from './definitions';
export { AssetUpload };
