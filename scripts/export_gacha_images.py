"""Export game artwork into standalone web previews. No Unity/server build required.
Requires Pillow. Existing web banners are retained; sources are recorded in docs.
"""
from pathlib import Path
import argparse
import json
import re
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]

def custom_preview(client):
    parts = client/'Assets/Resources_Src/Effect/Eff_Texture/Ui/Eff_UI_Jiemian_02'
    atlas = Image.open(parts/'Eff_UI_Jiemian_02.png').convert('RGBA')
    metadata = (parts/'Eff_UI_Jiemian_02.png.meta').read_text(encoding='utf-8-sig')
    rects = {}
    for block in re.split(r'    - serializedVersion: 2\n', metadata[metadata.index('  spriteSheet:'):])[1:]:
        match = re.search(r'      internalID: (\d+)', block)
        if match:
            rects[int(match[1])] = {key:int(re.search(r'        '+key+r': (\d+)', block)[1])
                                   for key in ('x','y','width','height')}
    canvas = Image.open(client/'Assets/Resources/UI/Texture/DrawCard/DrawCardStarBG.png').convert('RGBA').resize((1244,888))
    def paint(image, x, y, sx=1, sy=None):
        sy = sx if sy is None else sy
        image = image.resize((round(image.width*sx*.88),round(image.height*sy*.88)),Image.Resampling.LANCZOS)
        center = (622+(x*.88-.55)*100,444-y*.88*100)
        canvas.alpha_composite(image,(round(center[0]-image.width/2),round(center[1]-image.height/2)))
    def sprite(id):
        r=rects[id]
        return atlas.crop((r['x'],atlas.height-r['y']-r['height'],r['x']+r['width'],atlas.height-r['y']))
    # Static thumbnail of the pool's animated scene, using its original asset parts.
    paint(Image.open(parts/'Eff_T_xiaowu_dashu_01_01_1.png').convert('RGBA'),-3.738,3.501,2)
    paint(Image.open(parts/'Eff_T_xiaowu_dashu_01_06.png').convert('RGBA'),-4.24,1.65,1.6)
    paint(sprite(21300002),-4.89,3.7)
    paint(sprite(21300006),-1.14,-.96000004,1.3589808)
    paint(sprite(21300010),.74,-2.72,1.1)
    paint(sprite(21300008),.887,-2.056)
    paint(Image.open(parts/'Eff_T_xiaowu_toufa_02.png').convert('RGBA'),-2.92,1.604,1.4629737,1.4663607)
    paint(Image.open(parts/'Eff_T_xiaowu_toufa_03.png').convert('RGBA'),-1.674,1.367,.7923943,1.1756917)
    paint(Image.open(parts/'Eff_T_xiaowu_toufa_01.png').convert('RGBA'),-2.335,1.994,1.4848444,1.7261317)
    return canvas

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--client-root',type=Path,default=ROOT.parent/'SoulLandDivine-client')
    parser.add_argument('--custom-only',action='store_true')
    args=parser.parse_args()
    sources=json.loads((ROOT/'docs/gacha-image-sources.json').read_text(encoding='utf-8'))
    for id,entry in sources.items():
        if args.custom_only and id!='10000': continue
        image=custom_preview(args.client_root) if id=='10000' else Image.open(args.client_root/entry['source']).convert('RGBA')
        image.thumbnail((960,720),Image.Resampling.LANCZOS)
        image.save(ROOT/'public'/entry['output'].lstrip('/'),quality=88,method=6)
        print('Exported',id,flush=True)
    mapping=ROOT/'server/utils/gacha-rate-up.ts'
    text=mapping.read_text(encoding='utf-8-sig')
    ids=sorted(int(p.stem) for p in (ROOT/'public/gacha').glob('*.webp') if p.stem.isdigit())
    block='const gachaPoolImages: Record<number, string> = {\n'+''.join(f"  {id}: '/gacha/{id}.webp',\n" for id in ids)+'}'
    text,count=re.subn(r'const gachaPoolImages: Record<number, string> = \{.*?\n\}',lambda _:block,text,count=1,flags=re.S)
    assert count==1
    mapping.write_bytes(text.replace('\n','\r\n').encode('utf-8'))

if __name__=='__main__':main()
