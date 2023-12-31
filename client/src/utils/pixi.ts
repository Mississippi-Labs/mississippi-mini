
export const loadAssets = (src:any, cb:any) => {
  const img = new Image();
  img.src = src;
  img.onload = () => {
    cb(img);
  }

  img.onerror = () => {
    console.error(`${src} not found`);
  }
}