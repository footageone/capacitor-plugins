export interface Photo {
  id: string;
  base64: string;
  dataUrl: string;
  filename: string;
  mediaType: string;
}

export interface PhotoLibraryPlugin {
  openPhotoPicker(): Promise<{ items: Photo[]}>;
}
