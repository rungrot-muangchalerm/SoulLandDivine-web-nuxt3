from pathlib import Path
import json, shutil, xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[2]
WEB=ROOT/'SoulLandDivine-web-nuxt3'
CLIENT=ROOT/'SoulLandDivine-client/Assets'
XML=CLIENT/'Resources/XML'
OUT=WEB/'public/code-cards'

def rows(path):
    return [dict(e.attrib) for e in ET.parse(path).getroot().findall('class')]
def load(name): return json.loads((WEB/'data'/name).read_text(encoding='utf-8-sig'))
def copy(path, group):
    if not path.is_file(): return None
    target=OUT/group/path.name
    target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(path,target)
    return '/code-cards/'+group+'/'+path.name

def sprite(atlas,icon,group):
    candidates=list((CLIENT/'UIAtlasSprites'/atlas).rglob(icon+'.png'))
    return copy(candidates[0],group) if candidates else None

def main():
    names=load('email-item-names.json')
    hero_gods={r['HeroCardClientId']:r for r in rows(XML/'Client/HeroGod/HeroGodDetailClient.xml') if r.get('HeroCardClientId') and r['id']!='0'}
    server_heroes={r['id']:r for r in rows(XML/'Server/Hero/HeroCard.xml')}
    client_heroes={r['id']:r for r in rows(XML/'l10n_TH_gen/Client/Hero/HeroCardClient.xml')}
    # Special 21xxx/22xxx variants are not present in HeroCard.xml. Prefer
    # their same-named base-id hero, otherwise an unambiguous base-hero name.
    base_jobs_by_name={}
    for hero_id, config in server_heroes.items():
        localized=client_heroes.get(hero_id)
        if localized:
            base_jobs_by_name.setdefault(localized['HeroName'],set()).add(int(config['Job']))
    def hero_job(row):
        hero_id=row['id']
        if hero_id in server_heroes:
            return int(server_heroes[hero_id]['Job'])
        if len(hero_id)==5 and hero_id[:2] in ('21','22'):
            base=str(int(hero_id[-3:]))
            localized=client_heroes.get(base)
            if base in server_heroes and localized and localized.get('HeroName')==row['HeroName']:
                return int(server_heroes[base]['Job'])
        jobs=base_jobs_by_name.get(row['HeroName'],set())
        return next(iter(jobs)) if len(jobs)==1 else None

    base_qualities_by_name={}
    for hero_id, config in server_heroes.items():
        localized=client_heroes.get(hero_id)
        if localized:
            base_qualities_by_name.setdefault(localized['HeroName'],set()).add(int(config['Quality']))
    def hero_quality(row):
        hero_id=row['id']
        if hero_id in server_heroes:
            return int(server_heroes[hero_id]['Quality'])
        if len(hero_id)==5 and hero_id[:2] in ('21','22'):
            base=str(int(hero_id[-3:]))
            localized=client_heroes.get(base)
            if base in server_heroes and localized and localized.get('HeroName')==row['HeroName']:
                return int(server_heroes[base]['Quality'])
        qualities=base_qualities_by_name.get(row['HeroName'],set())
        return next(iter(qualities)) if len(qualities)==1 else None

    # HeroGodCard includes both ordinary illustrations (21xxx) and awakened
    # alternate forms (22xxx). Pick only the ordinary illustration, matched
    # by the localized hero name so normal/base and special IDs share artwork.
    normal_portraits_by_name={}
    normal_icons_by_name={}
    for hero_id, config in client_heroes.items():
        if len(hero_id)==5 and hero_id.startswith('21') and hero_id in hero_gods:
            normal_name=config['HeroName']
            candidate=CLIENT/'Resources/UI/Texture/HeroGodCard'/(hero_gods[hero_id]['GodCardImage']+'.png')
            if candidate.is_file():
                normal_portraits_by_name[normal_name]=candidate
        if len(hero_id)==5 and hero_id.startswith('21'):
            normal_icons_by_name[config['HeroName']]=(config.get('Atlas','hero_icon'),config.get('Icon',''))
    heroes=[]
    for r in rows(XML/'l10n_TH_gen/Client/Hero/HeroCardClient.xml'):
        if int(r['id'])<21: continue
        icon=sprite(r.get('Atlas','hero_icon'),r.get('Icon',''),'heroes')
        if not icon: continue
        h=dict(id=r['id'],name=r['HeroName'],iconUrl=icon,rewardType='7',job=hero_job(r),quality=hero_quality(r))
        normal_portrait=normal_portraits_by_name.get(r['HeroName'])
        portrait=copy(normal_portrait,'portraits') if normal_portrait else None
        if not portrait and r['id'].startswith('22'):
            # Never fall back to an awakened-form icon when the normal portrait
            # is unavailable; prefer the normal 21xxx icon of the same hero.
            normal_icon=normal_icons_by_name.get(r['HeroName'])
            if normal_icon:
                icon=sprite(normal_icon[0],normal_icon[1],'heroes') or icon
        h['portraitUrl']=portrait or icon
        h['portraitKind']='illustration' if portrait else 'icon'
        heroes.append(h)
    ring_text={r['id']:r for r in rows(XML/'l10n_TH_gen/Client/Text/SoulRing/SoulRing_Text.xml')}
    # Each SoulRing.Element list is the only allowed set for that creature.
    element_names=rows(XML/'l10n_TH_gen/Client/Text/SoulRing/SoulRingElement_Text.xml')
    ring_elements=[]
    for element in element_names:
        icon=sprite(element.get('Atlas','soul_ring'),element.get('Icon',''),'ring-elements')
        if icon:
            ring_elements.append(dict(id=element['id'],name=element['NameText'],iconUrl=icon,description=element.get('Resume','')))
    hunting_dungeons=rows(XML/'Server/Hunting/HuntingBase.xml')
    hunting_names={r['id']:r['name'] for r in hunting_dungeons}
    assert len(hunting_dungeons)==30
    rings=[]
    for r in rows(XML/'Server/SoulRing/SoulRing.xml'):
        if r['Icon']=='item_lingshi': continue # Client placeholder, not a creature ring image.
        icon=sprite(r['Atlas'],r['Icon'],'rings')
        if not icon: continue
        text=ring_text.get(r['id'],{})
        hunting_base_id=int(r['HuntingBaseId'])
        is_dungeon_ring=r['CEHUA']==hunting_names.get(str(hunting_base_id))
        rings.append(dict(id=r['id'],name=text.get('ItemName') or r.get('CEHUA',r['id']),iconUrl=icon,rewardType='3',backgroundUrl=sprite('item',r['IconBG'],'rings'),frameUrl=sprite('item','item_soul_ring_quality_'+r['Color'],'rings'),maxYear=int(r['MaxYear']),elementIds=r.get('Element','').split('|') if r.get('Element') else [],effect=text.get('Resume',''),sourceName=r.get('CEHUA',''),huntingBaseId=hunting_base_id,isDungeonRing=is_dungeon_ring))
    # The 30 primary SoulRing/Hunting dungeon drops follow HuntingBase ID.
    # Other/special/story rings remain available after the main dungeon progression.
    rings.sort(key=lambda ring: (not ring['isDungeonRing'],ring['huntingBaseId'],int(ring['id'])))
    assert [x['huntingBaseId'] for x in rings if x['isDungeonRing']]==list(range(1,31))

    equipment_rows={r['id']:r for r in rows(XML/'Server/Equipment/Equipment.xml')}
    equipment_slots={'1':'neck','2':'ring','3':'wrist','4':'boots'}
    ring_frames=[dict(minYear=int(r['MinYear']),maxYear=int(r['MaxYear']),quality=int(r['Quality']),color=int(r['Color']),frameUrl=sprite('item','item_soul_ring_quality_'+r['Color'],'rings')) for r in rows(XML/'Client/SoulRing/SoulRingColor.xml')]
    equipment=[]
    weapons=[]
    for kind,file,folder,result in [('5','email-equipment-icons.json','icons_equipment',equipment),('13','email-hidden-weapon-icons.json','icons_hidden_weapons',weapons)]:
        for id,icon in load(file).items():
            path=WEB/'public'/folder/(icon+'.png')
            if path.exists():
                entry=dict(id=id,name=names.get(kind,{}).get(id,id),iconUrl='/'+folder+'/'+path.name,rewardType=kind)
                if kind=='5':
                    config=equipment_rows[id]
                    entry.update(slot=equipment_slots[config['Part']],partType=int(config['Part']),quality=int(config['Color']),star=int(config['Star']),job=int(config['Job']))
                result.append(entry)
    specs={r['id']:r for r in rows(XML/'Server/SoulBone/SoulBoneSpec.xml')}
    affixes=[]
    affix_icon=sprite('item','item_soul_bone_1','bones')
    for r in rows(XML/'l10n_TH_gen/Client/Text/SoulBone/SoulBoneSpec_Text.xml'):
        if r['id'] not in specs: continue
        affixes.append(dict(id=r['id'],name=r['Text'],effect=r['Text'],iconUrl=affix_icon,rewardType='4',quality=int(specs[r['id']]['Quality'])))
    default_ids=['111024','111025','111012','111020','111026','111021','111010','111014','111033','111002']
    catalog=dict(ringFrames=ring_frames,ringElements=ring_elements,heroes=heroes,rings=rings,equipment=equipment,weapons=weapons,boneAffixes=affixes,defaultCard=dict(name=next(h['name'] for h in heroes if h['id']=='23'),heroId='23',equipment=[dict(id='',stars=0,level=0) for _ in range(5)],rings=[dict(id=id,year=1000000) for id in default_ids],talent='body',talentValue=35,boneAffixes=[]),sources=dict(heroes='Client/Hero/HeroCardClient.xml + HeroGodDetailClient.xml',rings='Server/SoulRing/SoulRing.xml + Server/Hunting/HuntingBase.xml (dungeon order) + localized SoulRing_Text.xml; UI Panel_SoulRingDetails.lua',boneAffixes='Server/SoulBone/SoulBoneSpec.xml + localized SoulBoneSpec_Text.xml'))
    (WEB/'data/code-card-catalog.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    for group in ['heroes','rings','ringElements','equipment','weapons','boneAffixes']:
        assert len(catalog[group])>0,group
        assert len({x['id'] for x in catalog[group]})==len(catalog[group]),group
        for item in catalog[group]:
            for key in ['iconUrl','portraitUrl','frameUrl','backgroundUrl']:
                if item.get(key): assert (WEB/'public'/item[key].lstrip('/')).is_file(),item
    assert len(ring_elements)==19
    assert all(all(any(e['id']==eid for e in ring_elements) for eid in r['elementIds']) for r in rings)
    assert all(any(x['id']==id for x in rings) for id in default_ids)
    assert any(x['id']=='23' for x in heroes)
    default=catalog['defaultCard']
    assert set(default)=={'name','heroId','talent','talentValue','boneAffixes','equipment','rings'}
    assert default['name']==next(h['name'] for h in heroes if h['id']==default['heroId'])
    assert len(default['equipment'])==5
    assert all(set(e)=={'id','stars','level'} and e==dict(id='',stars=0,level=0) for e in default['equipment'])
    assert len(default['rings'])==10 and all(set(r)=={'id','year'} for r in default['rings'])
    assert all(e['slot'] in equipment_slots.values() and e['job'] in range(1,6) for e in equipment)
    assert next(h for h in heroes if h['id']=='23')['job']==2
    assert next(h for h in heroes if h['id']=='21023')['job']==2
    assert next(h for h in heroes if h['id']=='22030')['job']==1
    assert all(f['frameUrl'] and (WEB/'public'/f['frameUrl'].lstrip('/')).is_file() for f in ring_frames)
    print(json.dumps({k:len(catalog[k]) for k in ['heroes','rings','equipment','weapons','boneAffixes']}))
    print('Verified every catalog image and default ID exists.')
if __name__=='__main__': main()
