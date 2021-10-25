import { WebPlugin } from '@capacitor/core';

import type { PhotoLibraryPlugin, Photo} from './definitions';

export class PhotoLibraryWeb extends WebPlugin implements PhotoLibraryPlugin {
  async openPhotoPicker(): Promise<{ items: Photo[]}> {
    const items = await this.fileInputExperience();
    return {items};
  }

  private fileInputExperience(): Promise<Photo[]> {
    let input = document.querySelector(
        '#_capacitor-camera-input',
    ) as HTMLInputElement;

    const cleanup = () => {
      input.parentNode?.removeChild(input);
    };
    return new Promise((resolve) => {
      if (!input) {
        input = document.createElement('input') as HTMLInputElement;
        input.id = '_capacitor-camera-input';
        input.type = 'file';
        input.accept = 'image/*';
        input.multiple = true;
        input.hidden = true;
        document.body.appendChild(input);
        input.addEventListener('change', (_e: any) => {
          if (input.files != null) {
            Promise.all(Array.from(input.files).map(file => {
              return new Promise<Photo>(resolve => {
                let format = 'jpeg';

                if (file.type === 'image/png') {
                  format = 'png';
                } else if (file.type === 'image/gif') {
                  format = 'gif';
                }

                const reader = new FileReader();

                reader.addEventListener('load', () => {
                  const dataUrl = reader.result as string
                  const b64 = dataUrl.split(',')[1];
                  resolve({
                    id: file.name,
                    dataUrl,
                    base64: b64,
                    format,
                  } as any as Photo);
                });
              })

            })).then(photos => {
              resolve(photos)
            })
          }
          cleanup();
        });
      }
      (input as any).capture = true;

      input.click();
    })
  }
}
