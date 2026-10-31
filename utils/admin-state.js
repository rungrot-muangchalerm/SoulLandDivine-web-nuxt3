import { reactive } from 'vue'

const initialWords = {
        // Header、Home、Sidebar部分
        commonStructure: {
            minstrelManagementSystem: 'ระบบจัดการ GM Douluo Continent',
            navBar: [],
            barList: [
                {
                    index: 'role',
                    title: 'ข้อมูลผู้เล่น',
                    limit: 0
                },
                {
                    index: '5',
                    title: 'หักทรัพยากร',
                    limit: 4,
                    subs: [
                        {
                            index: 'item',
                            title: 'หักไอเทม'
                        },
                        {
                            index: 'recharge',
                            title: 'หักความคืบหน้าการเติมเงินสะสม'
                        },
                        {
                            index: 'activity',
                            title: 'หักความคืบหน้าการเติมเงินกิจกรรม'
                        }
                    ]
                },
                {
                    index: 'boradcast',
                    title: 'ประกาศข้อความ',
                    limit: 2
                },
                {
                    index: 'notice',
                    title: 'ประกาศ',
                    limit: 'admin'
                },
                {
                    index: 'email',
                    title: 'ส่งอีเมล',
                    limit: 3
                },
                {
                    index: 'pay',
                    title: 'เติมเงินย้อนหลัง',
                    limit: 3
                },
                {
                    index: 'sensitive',
                    title: 'คำต้องห้าม',
                    limit: 1
                },
                {
                    index: 'server',
                    title: 'เปิดเซิร์ฟเวอร์ด่วน',
                    limit: 'server'
                },
                {
                    index: 'report',
                    title: 'จัดการรายงาน',
                    limit: 1
                },
                {
                    index: '2',
                    title: 'จัดการของรางวัล',
                    limit: 3,
                    subs: [
                        {
                            index: 'grade',
                            title: 'จัดการระดับรางวัล'
                        },
                        {
                            index: 'player',
                            title: 'จัดการผู้เล่น'
                        }
                    ]
                },
                {
                    index: '3',
                    title: 'ค้นหาบันทึก',
                    limit: 0,
                    subs: [
                        {
                            index: 'ItemConsume',
                            title: 'ค้นหาการใช้ไอเทม'
                        },
                        {
                            index: 'ItemProduce',
                            title: 'ค้นหาการได้รับไอเทม'
                        },
                        {
                            index: 'CurrencyConsume',
                            title: 'ค้นหาการใช้สกุลเงิน'
                        },
                        {
                            index: 'CurrencyProduce',
                            title: 'ค้นหาการได้รับสกุลเงิน'
                        },
                        {
                            index: 'conlog',
                            title: 'ประวัติเข้าและออกจากระบบ'
                        },
                        {
                            index: 'paylog',
                            title: 'ค้นหาการเติมเงิน'
                        }
                    ]
                },
                {
                    index: 'set',
                    title: 'จัดการการตั้งค่า',
                    limit: 'server',
                    subs: [
                        {
                            index: 'channel',
                            title: 'จัดการช่องทาง'
                        },
                        // {
                        //     index: 'consume',
                        //     title: '道具、货币消耗途径管理'
                        // },
                        // {
                        //     index: 'gain',
                        //     title: '道具、货币获取途径管理'
                        // },
                        // {
                        //     index: 'resource',
                        //     title: '资源扣除类型管理'
                        // }
                    ]
                },
                {
                    index: '1',
                    title: 'จัดการสิทธิ์',
                    limit: 'admin',
                    subs: [
                        {
                            index: 'user',
                            title: 'จัดการผู้ใช้'
                        },
                        {
                            index: 'operating',
                            title: 'ประวัติการดำเนินการ'
                        }
                    ]
                }/* ,
                {
                    index: '404',
                    title: 'หน้า 404'
                },
                {
                    index: '403',
                    title: 'หน้า 403'
                } */
            ]
        },
        // 资源类型
        resource: {
            type_list: [
                {
                    value: '1',
                    label: 'สกุลเงิน'
                }, {
                    value: '2',
                    label: 'ไอเทมทั่วไป (ไม่ใช่อุปกรณ์หรือกระดูกวิญญาณ โดยมากเป็นไอเทมใช้แล้วหมดไป)'
                }, {
                    value: '3',
                    label: 'วงแหวนวิญญาณ'
                }, {
                    value: '4',
                    label: 'กระดูกวิญญาณ'
                }, {
                    value: '5',
                    label: 'อุปกรณ์'
                }, {
                    value: '13',
                    label: 'อาวุธลับ'
                }, {
                    value: '9',
                    label: 'ชิ้นส่วนตัวละคร'
                }, {
                    value: '11',
                    label: 'กรอบข้อความ'
                }, {
                    value: '21',
                    label: 'ไข่สัตว์เลี้ยง'
                }
            ],
            activity_type: [
                {
                    value: '4',
                    label: 'ซื้อสะสม 7 วัน, โปรโมชันเซิร์ฟเวอร์ใหม่, สมบัติจักรพรรดิเงินคราม, พรจากเทพธิดา, พรตะวันเจิดจ้า, ของขวัญม้าน้ำ, มิติเทพสงคราม, หุบเขาโลหิตแห่งหายนะ และโปรโมชัน 51'
                }, {
                    value: '5',
                    label: 'พลิกการ์ดนำโชค'
                }, {
                    value: '7',
                    label: 'ตรีศูล, กล่องดนตรี, ถอนแครอท'
                }
            ]
        },
        // 日期时间选择快捷方式
        time: {
            pickerHour: {
                start: '00:00',
                step: '01:00',
                end: '23:00'
            },
            pickerDay: {
                disabledDate(time) {
                    return time.getTime() > Date.now();
                },
                shortcuts: [{
                    text: 'วันนี้',
                    onClick(picker) {
                        picker.$emit('pick', new Date());
                    }
                }, {
                    text: 'เมื่อวาน',
                    onClick(picker) {
                        const date = new Date();
                        date.setTime(date.getTime() - 3600 * 1000 * 24);
                        picker.$emit('pick', date);
                    }
                }, {
                    text: 'หนึ่งสัปดาห์ก่อน',
                    onClick(picker) {
                        const date = new Date();
                        date.setTime(date.getTime() - 3600 * 1000 * 24 * 7);
                        picker.$emit('pick', date);
                    }
                }]
            },
            pickerInterval: {
                shortcuts: [{
                    text: '7 วันที่ผ่านมา',
                    onClick(picker) {
                        const end = new Date();
                        const start = new Date();
                        start.setTime(start.getTime() - 3600 * 1000 * 24 * 7);
                        picker.$emit('pick', [start, end]);
                    }
                }, {
                    text: 'เดือนที่ผ่านมา',
                    onClick(picker) {
                        const end = new Date();
                        const start = new Date();
                        start.setTime(start.getTime() - 3600 * 1000 * 24 * 30);
                        picker.$emit('pick', [start, end]);
                    }
                }, {
                    text: '3 เดือนที่ผ่านมา',
                    onClick(picker) {
                        const end = new Date();
                        const start = new Date();
                        start.setTime(start.getTime() - 3600 * 1000 * 24 * 90);
                        picker.$emit('pick', [start, end]);
                    }
                }]
            }
        },
        // 弹窗标题
        title: {
            addSensitiveWord: 'เพิ่มคำต้องห้าม',
            changeSensitiveWord: 'แก้ไขคำต้องห้าม'
        },
        // 按钮
        button: {
            Fullscreen: 'เต็มหน้าจอ',
            cancleFullscreen: 'ออกจากโหมดเต็มหน้าจอ',
            changePassword: 'เปลี่ยนรหัสผ่าน',
            add: 'เพิ่ม',
            deleteBtn: 'ลบ',
            change: 'แก้ไข',
            search: 'ค้นหา',
            submit: 'ส่ง',
            yes: 'ตกลง',
            no: 'ยกเลิก',
            silence: 'ปิดแชต',
            removeSilence: 'เปิดแชต',
            freeze: 'ระงับบัญชี',
            removeFreeze: 'ยกเลิกการระงับบัญชี',
            logout: 'ออกจากระบบ',
            choose: 'เลือก '
        },
        // 提示文字
        tips: {
            PleaseInputUID: 'กรอกรหัสตัวละคร',
            PleaseInputRolename: 'กรอกชื่อตัวละคร',
            PleaseSelectServerID: 'เลือก ServerID',
            PleaseInputMinutes: 'กรอกระยะเวลา (นาที)',
            PleaseInputHours: 'กรอกระยะเวลา (ชั่วโมง)',
            PleaseInputReason: 'กรอกเหตุผล (ไม่บังคับ)',
            PleaseInputSensitiveWord: 'กรอกคำต้องห้าม',
            startTime: 'เวลาเริ่มต้น',
            to: 'ถึง',
            endTime: 'เวลาสิ้นสุด',
            PleaseCompleteCondition: 'มีช่องว่างที่ยังไม่ได้กรอก กรุณากรอกให้ครบ!',
            noData: 'ไม่พบข้อมูล'
        },
        // 结果表格头部
        resultHeader: {
            serverId: 'ServerID',
			id: 'id',
            roleId: 'รหัสตัวละคร',
            uid: 'รหัสผู้ใช้',
            name: 'ชื่อ',
            sex: 'เพศ',
            account: 'บัญชี',
            online: 'สถานะการเข้าสู่ระบบ',
            time: 'เวลา',
            registTime: 'เวลาสมัคร',
            lastLoginTime: 'เวลาเข้าสู่ระบบล่าสุด',
            silenceTime: 'ระยะเวลาปิดแชต',
            freezeTime: 'ระยะเวลาระงับบัญชี',
            content: 'เนื้อหา',
            level: 'เลเวล',
            diamond: 'เพชร',
			sensitiveWord: 'คำต้องห้าม',
            handle: 'การดำเนินการ'
        },
        // 操作行为
        operation: {
            operationList: [
                {
                    index: '/login',
                    label: 'เข้าสู่ระบบ'
                },{
                    index: '/role/search',
                    label: 'ค้นหาข้อมูลตัวละคร'
                },{
                    index: '/role/unVoice',
                    label: 'ปิดแชต'
                },{
                    index: '/role/voice',
                    label: 'ยกเลิกการปิดแชต'
                },{
                    index: '/role/freeze',
                    label: 'ระงับบัญชี'
                },{
                    index: '/role/unFreeze',
                    label: 'ยกเลิกการระงับบัญชี'
                },{
                    index: '/broadcast/search',
                    label: 'ค้นหาประกาศข้อความ'
                },{
                    index: '/broadcast/add',
                    label: 'เพิ่มประกาศข้อความ'
                },{
                    index: '/broadcast/update',
                    label: 'แก้ไขประกาศข้อความ'
                },{
                    index: '/broadcast/delete',
                    label: 'ลบประกาศข้อความ'
                },{
                    index: '/email/send',
                    label: 'ส่งอีเมล'
                },{
                    index: '/sensitive/addword',
                    label: 'เพิ่มคำต้องห้าม'
                },{
                    index: '/log/searchItemConsume',
                    label: 'ค้นหาการใช้ไอเทม'
                },{
                    index: '/log/searchItemProduce',
                    label: 'ค้นหาการได้รับไอเทม'
                },{
                    index: '/log/searchCurrencyConsume',
                    label: 'ค้นหาการใช้สกุลเงิน'
                },{
                    index: '/log/searchCurrencyProduce',
                    label: 'ค้นหาการได้รับสกุลเงิน'
                },{
                    index: '/log/searchLoginOrLogOut',
                    label: 'ค้นหาประวัติเข้าและออกจากระบบ'
                },{
                    index: '/log/searchPay',
                    label: 'ค้นหาการเติมเงิน'
                },{
                    index: '/welfare/searchGrade',
                    label: 'ค้นหาระดับของรางวัล'
                },{
                    index: '/welfare/addGrade',
                    label: 'เพิ่มระดับของรางวัล'
                },{
                    index: '/welfare/changeGrade',
                    label: 'แก้ไขระดับของรางวัล'
                },{
                    index: '/welfare/deleteGrade',
                    label: 'ลบระดับของรางวัล'
                },{
                    index: '/welfare/searchPlayer',
                    label: 'ค้นหาผู้เล่นที่ได้รับของรางวัล'
                },{
                    index: '/welfare/addPlayer',
                    label: 'เพิ่มผู้เล่นที่ได้รับของรางวัล'
                },{
                    index: '/welfare/deletePlayer',
                    label: 'ลบผู้เล่นที่ได้รับของรางวัล'
                },{
                    index: '/servers/getServers',
                    label: 'ค้นหารายชื่อเซิร์ฟเวอร์'
                },{
                    index: '/servers/isRecommend',
                    label: 'เปิดการแนะนำ'
                },{
                    index: '/servers/isMaintain',
                    label: 'เปิดหรือปิดปรับปรุงระบบ'
                },{
                    index: '/servers/isMaintainAll',
                    label: 'ปรับปรุงระบบทุกเซิร์ฟเวอร์'
                },{
                    index: '/servers/isMaintainAllCancel',
                    label: 'ยกเลิกการปรับปรุงระบบทุกเซิร์ฟเวอร์'
                },{
                    index: '/servers/isOpen',
                    label: 'เปิดหรือปิดเซิร์ฟเวอร์'
                },{
                    index: '/report/search',
                    label: 'ค้นหาข้อมูลรายงาน'
                },{
                    index: '/report/ignore',
                    label: 'ละเว้นรายงาน'
                },{
                    index: '/pay/order',
                    label: 'เติมเงินย้อนหลัง'
                },{
                    index: '/itemdelete/search',
                    label: 'ค้นหาทรัพยากร'
                },{
                    index: '/itemdelete/deduct',
                    label: 'หักทรัพยากร'
                },{
                    index: '/itemdelete/deductPlan',
                    label: 'หักความคืบหน้าการเติมเงินสะสม'
                }
            ]
        },
        // 消耗、获取途径列表
        myListArr: {
            // 道具、货币消耗途径
            consumeWay: [
                {
                    value: 'All',
                    label: 'ทั้งหมด'
                },
                {
                    value: 'OpenChest',
                    label: 'เปิดหีบสมบัติ'
                },
                {
                    value: 'HeroUpgrade',
                    label: 'อัปเลเวลฮีโร่'
                },
                {
                    value: 'SkillUpgrade',
                    label: 'อัปเกรดทักษะ'
                },
                {
                    value: 'ItemSell',
                    label: 'ขายไอเทม (ใช้ไอเทม)'
                },
                {
                    value: 'ItemUse',
                    label: 'ใช้ไอเทม'
                },
                {
                    value: 'ShopCard ',
                    label: 'ซื้อฮีโร่และทักษะจากร้านค้า'
                },
                {
                    value: 'ShopChest',
                    label: 'ซื้อหีบสมบัติจากร้านค้า'
                },
                {
                    value: 'ShopGold',
                    label: 'ซื้อเหรียญทองจากร้านค้า'
                },
                {
                    value: 'Shop',
                    label: 'ค่าเริ่มต้นของร้านค้า'
                },
                {
                    value: 'TaskItemUse',
                    label: 'ใช้ไอเทมภารกิจ'
                },
                {
                    value: 'BuyCount',
                    label: 'จำนวนครั้งที่ซื้อ'
                },
                {
                    value: 'BattleWin ',
                    label: 'ชนะการต่อสู้'
                },
                {
                    value: 'BattleFail',
                    label: 'แพ้การต่อสู้'
                },
                {
                    value: 'BattleTie',
                    label: 'เสมอในการต่อสู้'
                },
                {
                    value: 'ChangeName',
                    label: 'เปลี่ยนชื่อ'
                },
                {
                    value: 'ItemBuy',
                    label: 'ซื้อไอเทม'
                },
                {
                    value: 'SkinBuy',
                    label: 'ซื้อสกิน'
                },
                {
                    value: 'UseTrumpet',
                    label: 'แตรแชต'
                },
                {
                    value: 'SeasonReward',
                    label: 'รางวัลประจำซีซัน'
                },
                {
                    value: 'PresentGift',
                    label: 'มอบของขวัญ'
                },
                {
                    value: 'Activity',
                    label: 'กิจกรรม'
                },
                {
                    value: 'BattleResult',
                    label: 'ผลการต่อสู้'
                },
                {
                    value: 'DailyQuestion',
                    label: 'ตอบคำถามประจำวัน'
                },
                {
                    value: 'BreakUp',
                    label: 'แยกชิ้นส่วน'
                },
                {
                    value: 'Compose',
                    label: 'หลอมรวม'
                },
                {
                    value: 'StoryLine',
                    label: 'เนื้อเรื่อง'
                },
                {
                    value: 'TreasureMap',
                    label: 'แผนที่สมบัติ'
                },
                {
                    value: 'ItemGameLevel',
                    label: 'ด่านไอเทม'
                },
                {
                    value: 'PVEHeroUpgrade',
                    label: 'อัปเกรด PVE'
                },
                {
                    value: 'PVEMainHeroUpgrade',
                    label: 'อัปเกรดตัวเอก PVE'
                },
                {
                    value: 'Fishing',
                    label: 'ตกปลา'
                },
                {
                    value: 'ShopFish1',
                    label: 'ซื้อจากร้านค้า 1'
                },
                {
                    value: 'ShopFish2',
                    label: 'ซื้อจากร้านค้า 2'
                },
                {
                    value: 'ConvertFishCoin',
                    label: 'แลกเหรียญปลา'
                },
                {
                    value: 'RadioGiveGift',
                    label: 'ส่งของขวัญ'
                },
                {
                    value: 'HeroLevelUp',
                    label: 'อัปเกรดวิญญาณยุทธ์'
                },
                {
                    value: 'HeroAwaken',
                    label: 'ปลุกพลังวิญญาณยุทธ์'
                },
                {
                    value: 'SmeltSoulBone',
                    label: 'หลอมกระดูกวิญญาณ'
                },
                {
                    value: 'HeroResetTalent',
                    label: 'รีเซ็ตพรสวรรค์'
                },
                {
                    value: 'Forge',
                    label: 'สร้าง'
                },
                {
                    value: 'BagSpaceInc',
                    label: 'ขยายกระเป๋า'
                },
                {
                    value: 'CampStarLevelUp',
                    label: 'อัปเกรดการพัฒนาฝ่าย'
                },
                {
                    value: 'EquipmentUpgrade',
                    label: 'อัปเกรดอุปกรณ์'
                },
                {
                    value: 'EquipmentCrack',
                    label: 'อุปกรณ์แตกสลาย'
                },
                {
                    value: 'EquipmentInjection',
                    label: 'ถ่ายโอนพลังสู่อุปกรณ์'
                },
                {
                    value: 'EquipmentLevelRollBack',
                    label: 'ย้อนระดับอุปกรณ์'
                },
                {
                    value: 'Hunting',
                    label: 'ล่าวิญญาณอสูร'
                },
                {
                    value: 'BenefitsExp',
                    label: 'ดันเจียน EXP ของรางวัล'
                },
                {
                    value: 'BenefitsGold',
                    label: 'ดันเจียนเหรียญเงินของรางวัล'
                },
                {
                    value: 'BenefitsSoulPower',
                    label: 'ดินแดนที่ราบสูง'
                },
                {
                    value: 'BenefitsSoulBreath',
                    label: 'ดันเจียนดินแดนที่ราบสูง'
                },
                {
                    value: 'SecretAreaSweepCountBuy',
                    label: 'ซื้อในดินแดนลับ'
                },
                {
                    value: 'BuyFriendHeartGiveCount',
                    label: 'ซื้อจำนวนครั้งการมอบหัวใจ'
                },
                {
                    value: 'BuyFriendHeartTakeCount',
                    label: 'ซื้อจำนวนครั้งการรับหัวใจ'
                },
                {
                    value: 'ChangeCamp',
                    label: 'เปลี่ยนฝ่าย'
                },
                {
                    value: 'CampWorship',
                    label: 'สักการะฝ่าย'
                },
                {
                    value: 'BreakSoulSkill',
                    label: 'เสริมพลังวงแหวนวิญญาณ (ทะลวงขั้น)'
                },
                {
                    value: 'OnHook',
                    label: 'ฝึกจำลอง'
                },
                {
                    value: 'IntegralBossBuy',
                    label: 'บอสประจำชั่วโมง'
                },
                {
                    value: 'CompleteDelegation',
                    label: 'เร่งทำภารกิจมอบหมายให้เสร็จ'
                },
                {
                    value: 'RefreshDelegation',
                    label: 'รีเฟรชภารกิจมอบหมายด้วยตนเอง'
                },
                {
                    value: 'BuyDelegationCount',
                    label: 'ซื้อจำนวนครั้งมอบหมายภารกิจ'
                },
                {
                    value: 'ResetArenaFightTime',
                    label: 'รีเซ็ตเวลาท้าทายในสนามประลอง'
                },
                {
                    value: 'DrawHeroCard',
                    label: 'สุ่มการ์ด'
                },
                {
                    value: 'HeroUpSteps',
                    label: 'เลื่อนขั้นคู่หู'
                },
                {
                    value: 'Chapter',
                    label: 'บท'
                },
                {
                    value: 'BuyTimeSpacePower',
                    label: 'ซื้อพลังมิติเวลา'
                },
                {
                    value: 'BuyGodPathPower',
                    label: 'ซื้อพลังงานเส้นทางสู่เทพ'
                },
                {
                    value: 'GodPathFight',
                    label: 'การต่อสู้เจ็ดสำนักแห่งเส้นทางสู่เทพ'
                },
                {
                    value: 'BuyGodPathHeart',
                    label: 'ซื้อจำนวนครั้งหัวใจมหาสมุทร'
                },
                {
                    value: 'BuyGodPathTrident',
                    label: 'ซื้อจำนวนครั้งตรีศูล'
                },
                {
                    value: 'BuyGodPathTridentStrategy',
                    label: 'ใช้ความคล่องแคล่วของตรีศูล'
                },
                {
                    value: 'BuyGodPathTridentRandom',
                    label: 'เพิ่มรางวัลตรีศูลเป็นสองเท่า'
                },
                {
                    value: 'GodPathLightPuzzle',
                    label: 'เปิดชิ้นส่วนจิ๊กซอว์'
                },
                {
                    value: 'GodPathHeight',
                    label: 'ไต่หอคอยเส้นทางสู่เทพ'
                },
                {
                    value: 'WishPool',
                    label: 'บ่อน้ำอธิษฐาน'
                },
                {
                    value: 'BuyAction',
                    label: 'ซื้อพลังปฏิบัติการ'
                },
                {
                    value: 'CampBuildBuyDiceCount',
                    label: 'จำนวนครั้งต่อวันที่ซื้อได้สำหรับการสร้างฝ่าย'
                },
                {
                    value: 'PassCardClear',
                    label: 'รีเฟรชรอบบัตรผ่าน'
                },
                {
                    value: 'CampFortAddNature',
                    label: 'ไอเทมค่าสถานะฐานที่มั่นในสงครามฝ่าย'
                },
                {
                    value: 'Tower',
                    label: 'ชีวประวัติผู้ใช้วิญญาณ'
                },
                {
                    value: 'BuyResonanceGrid',
                    label: 'ปลดล็อกช่องสะท้อนวิญญาณยุทธ์'
                },
                {
                    value: 'EnhanceSoulSkill',
                    label: 'เสริมพลังทักษะวิญญาณ'
                },
                {
                    value: 'HeroGod',
                    label: 'ก้าวสู่เทพ'
                },
                {
                    value: 'TreasurePuzzle',
                    label: 'จิ๊กซอว์แผนที่สมบัติ'
                },
                {
                    value: 'CrossBattleBuyCount',
                    label: 'ซื้อจำนวนครั้งสงครามข้ามเซิร์ฟเวอร์'
                },
                {
                    value: 'ThemeBossBuyCount',
                    label: 'ซื้อจำนวนครั้งบอสธีม'
                },
                {
                    value: 'CrossGuessing',
                    label: 'วางเดิมพัน'
                },
                {
                    value: 'ReturnEquipmentUpgrade',
                    label: 'คืนวัสดุอัปเกรดอุปกรณ์'
                },
                {
                    value: 'HeroRevert',
                    label: 'รีเซ็ต'
                },
                {
                    value: 'BuyCultivateGift',
                    label: 'ซื้อแพ็กพัฒนาตัวละคร'
                },
                {
                    value: 'ShovelGameRevive',
                    label: 'ชุบชีวิตในมินิเกม'
                },
                {
                    value: 'HidderWeapon',
                    label: 'ฝึกเพื่อรับรางวัลอาวุธลับ'
                },
                {
                    value: 'BuyHidderWeaponItem',
                    label: 'รางวัลอาวุธลับ'
                },
                {
                    value: 'CrossBossBuyActionCount',
                    label: 'ซื้อจำนวนครั้งพลังปฏิบัติการบอสข้ามเซิร์ฟเวอร์'
                },
                {
                    value: 'BuySeaTreasureItem',
                    label: 'รางวัลเกาะ'
                },
                {
                    value: 'SeaTreasure',
                    label: 'เกาะ'
                },
                {
                    value: 'Garden',
                    label: 'สวนหอมกรุ่น'
                },
                {
                    value: 'SoulBoneQuenching',
                    label: 'หลอมวงแหวนวิญญาณ'
                },
                {
                    value: 'DivineLove',
                    label: 'ถามรักสวรรค์และปฐพี'
                },
                {
                    value: 'BuyDivineLoveItem',
                    label: 'ซื้อไอเทมถามรักสวรรค์และปฐพี'
                },
                {
                    value: 'IslandHigh',
                    label: 'ไต่หอคอยเกาะ'
                },
                {
                    value: 'HidderWeaponHigh',
                    label: 'รางวัลอาวุธลับขั้นสูง'
                },
                {
                    value: 'SeaTreasureHigh',
                    label: 'ผจญภัยเทพสมุทรขั้นสูง'
                },
                {
                    value: 'DivineLoveHigh',
                    label: 'ถามรักสวรรค์และปฐพีขั้นสูง'
                },
                {
                    value: 'DragonBoat',
                    label: 'กิจกรรมเทศกาลตวนอู่'
                },
                {
                    value: 'DragonBoatBuyTicket',
                    label: 'ซื้อตั๋วกิจกรรมเทศกาลตวนอู่'
                },
                {
                    value: 'StoneWall',
                    label: 'กำแพงศิลาห้าวเทียน'
                },
                {
                    value: 'StoneWallHigh',
                    label: 'กำแพงศิลาห้าวเทียนขั้นสูง'
                },
                {
                    value: 'BuyStoneWallItem',
                    label: 'ซื้อไอเทมกำแพงศิลาห้าวเทียน'
                },
                {
                    value: 'IslandChallenge',
                    label: 'ท้าทายเกาะ'
                },
                {
                    value: 'TravelHeroActivate',
                    label: 'เปิดใช้งานท่องโลก'
                },
                {
                    value: 'BuyCarnivalMallGift',
                    label: 'ร้านลดราคาคาร์นิวัล'
                },
                {
                    value: 'ButTravelShopItem',
                    label: 'ซื้อจากร้านท่องโลก'
                },
                {
                    value: 'HiddenWeaponUpgrade',
                    label: 'อัปเกรดอาวุธลับ'
                },
                {
                    value: 'HiddenWeapon',
                    label: 'อาวุธลับ'
                }
            ],
            // 道具、货币获取途径
            gainWay: [
                {
                    value: 'All',
                    label: 'ทั้งหมด'
                },
                {
                    value: 'OpenChest',
                    label: 'เปิดหีบสมบัติ'
                },
                {
                    value: 'HeroUpgrade',
                    label: 'อัปเลเวลฮีโร่'
                },
                {
                    value: 'SkillUpgrade',
                    label: 'อัปเกรดทักษะ'
                },
                {
                    value: 'BattleResult',
                    label: 'ผลการต่อสู้'
                },
                {
                    value: 'Task',
                    label: 'รางวัลภารกิจ'
                },
                {
                    value: 'Eamil',
                    label: 'รางวัลอีเมล'
                },
                {
                    value: 'ItemSell',
                    label: 'ขายไอเทมและรับสกุลเงินคืน'
                },
                {
                    value: 'ItemUse ',
                    label: 'ใช้ไอเทมเพื่อรับไอเทม'
                },
                {
                    value: 'ShopCard',
                    label: 'ซื้อฮีโร่และทักษะจากร้านค้า'
                },
                {
                    value: 'ShopChest',
                    label: 'ซื้อหีบสมบัติจากร้านค้า'
                },
                {
                    value: 'ShopGold',
                    label: 'ซื้อเหรียญทองจากร้านค้า'
                },
                {
                    value: 'ShopBuy',
                    label: 'ซื้อจากร้านค้า'
                },
                {
                    value: 'ShopSoulBone',
                    label: 'ร้านค้ากระดูกวิญญาณ'
                },
                {
                    value: 'BattleWin',
                    label: 'ชนะการต่อสู้'
                },
                {
                    value: 'BattleFail',
                    label: 'แพ้การต่อสู้'
                },
                {
                    value: 'BattleTie',
                    label: 'เสมอในการต่อสู้'
                },
                {
                    value: 'DailyLogin',
                    label: 'รับคะแนนจับคู่จากการเข้าสู่ระบบทุกวัน'
                },
                {
                    value: 'UpBattleLevel',
                    label: 'คะแนนโบนัสเลื่อนระดับ'
                },
                {
                    value: 'ItemBuy',
                    label: 'ซื้อไอเทม'
                },
                {
                    value: 'Recharge',
                    label: 'เติมเงิน'
                },
                {
                    value: 'Activity',
                    label: 'กิจกรรม'
                },
                {
                    value: 'DailyQuestion',
                    label: 'ตอบคำถามประจำวัน'
                },
                {
                    value: 'BreakUp',
                    label: 'แยกชิ้นส่วน'
                },
                {
                    value: 'Compose',
                    label: 'หลอมรวม'
                },
                {
                    value: 'LevelUp',
                    label: 'อัปเลเวลตัวเอก'
                },
                {
                    value: 'Refresh',
                    label: 'รีเฟรช'
                },
                {
                    value: 'StoryLine',
                    label: 'เนื้อเรื่อง'
                },
                {
                    value: 'TreasureMap',
                    label: 'แผนที่สมบัติ'
                },
                {
                    value: 'ItemGameLevel',
                    label: 'ด่านไอเทม'
                },
                {
                    value: 'OnePieceSweep',
                    label: 'กวาดล้างแผนที่ทะเล'
                },
                {
                    value: 'OnePieceBattle',
                    label: 'ผ่านด่านแผนที่ทะเล'
                },
                {
                    value: 'GetBait',
                    label: 'รับเหยื่อตกปลา'
                },
                {
                    value: 'Fishing',
                    label: 'ตกปลา'
                },
                {
                    value: 'ConvertFishCoin',
                    label: 'แลก'
                },
                {
                    value: 'RadioGiveGift',
                    label: 'ส่งของขวัญ'
                },
                {
                    value: 'RadioContributionReward',
                    label: 'รางวัลผลงาน'
                },
                {
                    value: 'StoryLineChest',
                    label: 'หีบสมบัติเนื้อเรื่อง'
                },
                {
                    value: 'TeamBoss',
                    label: 'บอสปาร์ตี้'
                },
                {
                    value: 'SmeltSoulBone',
                    label: 'หลอมกระดูกวิญญาณ'
                },
                {
                    value: 'Forge',
                    label: 'สร้าง'
                },
                {
                    value: 'EquipmentUpgrade',
                    label: 'อัปเกรดอุปกรณ์'
                },
                {
                    value: 'EquipmentCrack',
                    label: 'อุปกรณ์แตกสลาย'
                },
                {
                    value: 'EquipmentInjection',
                    label: 'ถ่ายโอนพลังสู่อุปกรณ์'
                },
                {
                    value: 'DelegationReward',
                    label: 'รางวัลภารกิจมอบหมาย'
                },
                {
                    value: 'FriendlyHeart',
                    label: 'เพื่อนส่งหัวใจ'
                },
                {
                    value: 'CampRankReward',
                    label: 'อันดับฝ่าย'
                },
                {
                    value: 'RandomChooseCamp',
                    label: 'สุ่มเลือกฝ่าย'
                },
                {
                    value: 'CampWorship',
                    label: 'สักการะฝ่าย'
                },
                {
                    value: 'StoryDungeon',
                    label: 'ดันเจียนเนื้อเรื่องเดี่ยว'
                },
                {
                    value: 'Hunting',
                    label: 'ล่าวิญญาณอสูร'
                },
                {
                    value: 'IntegralBoss',
                    label: 'บอสประจำชั่วโมง'
                },
                {
                    value: 'RankLevelReward',
                    label: 'รางวัลระดับ'
                },
                {
                    value: 'ChallengeResult',
                    label: 'สนามประลอง'
                },
                {
                    value: 'SecretAreaDungeon',
                    label: 'ดินแดนลับ'
                },
                {
                    value: 'SecretAreaSweep',
                    label: 'กวาดล้างดินแดนลับ'
                },
                {
                    value: 'PassTaskDailyReward',
                    label: 'รางวัลบัตรผ่านประจำวัน'
                },
                {
                    value: 'PassTaskLevelReward',
                    label: 'รางวัลระดับบัตรผ่าน'
                },
                {
                    value: 'DrawHeroCard',
                    label: 'สุ่มการ์ด'
                },
                {
                    value: 'Benefit',
                    label: 'บททดสอบผู้ใช้วิญญาณ'
                },
                {
                    value: 'Chapter',
                    label: 'บท'
                },
                {
                    value: 'BuyTimeSpacePower',
                    label: 'ซื้อพลังมิติเวลา'
                },
                {
                    value: 'TimeSpacePowerRecory',
                    label: 'ฟื้นฟูพลังมิติเวลาตามเวลา'
                },
                {
                    value: 'BuyGodPathPower',
                    label: 'ซื้อพลังงานเส้นทางสู่เทพ'
                },
                {
                    value: 'GodPathDaily',
                    label: 'รีเฟรชเส้นทางสู่เทพประจำวัน'
                },
                {
                    value: 'GodPathSevenFight',
                    label: 'เจ็ดสำนักแห่งเส้นทางสู่เทพ'
                },
                {
                    value: 'GodPathTask',
                    label: 'ภารกิจเส้นทางสู่เทพ'
                },
                {
                    value: 'GodPathHeight',
                    label: 'ไต่หอคอยเส้นทางสู่เทพ'
                },
                {
                    value: 'CrossActivityReward',
                    label: 'รางวัลกิจกรรมข้ามเซิร์ฟเวอร์'
                },
                {
                    value: 'CrossPreliminaryReward',
                    label: 'รางวัลรอบคัดเลือกข้ามเซิร์ฟเวอร์'
                },
                {
                    value: 'CrossPreliminaryResult',
                    label: 'รางวัลการต่อสู้รอบคัดเลือก'
                },
                {
                    value: 'WishPool',
                    label: 'บ่อน้ำอธิษฐาน'
                },
                {
                    value: 'CampBuild',
                    label: 'สร้างฝ่าย'
                },
                {
                    value: 'CampGather',
                    label: 'เก็บทรัพยากรของฝ่าย'
                },
                {
                    value: 'PassCardTask',
                    label: 'ภารกิจบัตรผ่าน'
                },
                {
                    value: 'PassCardBuyExp',
                    label: 'ซื้อ EXP บัตรผ่าน'
                },
                {
                    value: 'Tower',
                    label: 'ปีนหอคอย'
                },
                {
                    value: 'CampBattle',
                    label: 'ต่อสู้ที่ฐานฝ่าย'
                },
                {
                    value: 'CampTeamBattle',
                    label: 'ต่อสู้แบบทีมของฝ่าย'
                },
                {
                    value: 'CampBattleNeutral',
                    label: 'ฝ่ายเป็นกลางในสงคราม'
                },
                {
                    value: 'CampBox',
                    label: 'หีบสมบัติฝ่าย'
                },
                {
                    value: 'HeroRevert',
                    label: 'รีเซ็ตคู่หู'
                },
                {
                    value: 'Onhook',
                    label: 'ต่อสู้อัตโนมัติ'
                },
                {
                    value: 'PushFigure',
                    label: 'ผ่านด่าน'
                },
                {
                    value: 'ShovelTreasure',
                    label: 'ขุดสมบัติ'
                },
                {
                    value: 'Contribution',
                    label: 'ผลงาน'
                },
                {
                    value: 'ThemePassLevelReward',
                    label: 'รางวัลระดับบัตรผ่านธีม'
                },
                {
                    value: 'CrossServerReward',
                    label: 'รางวัลรวมทุกเซิร์ฟเวอร์'
                },
                {
                    value: 'GM',
                    label: 'เพิ่มจากระบบหลังบ้าน'
                },
                {
                    value: 'ReceiveItem',
                    label: 'รับไอเทม'
                },
                {
                    value: 'GetFirstRecharge',
                    label: 'รับรางวัลเติมเงินครั้งแรก'
                },
                {
                    value: 'RankReward',
                    label: 'รางวัลไต่อันดับ'
                },
                {
                    value: 'ReturnEquipmentUpgrade',
                    label: 'คืน'
                },
                {
                    value: 'TreasurePuzzle',
                    label: 'จิ๊กซอว์สมบัติ'
                },
                {
                    value: 'BuyCultivateGift',
                    label: 'ซื้อแพ็กพัฒนาตัวละคร'
                },
                {
                    value: 'HidderWeapon',
                    label: 'รางวัลอาวุธลับ'
                },
                {
                    value: 'BuyHidderWeaponItem',
                    label: 'รางวัลอาวุธลับ'
                },
                {
                    value: 'ReceiveFreePettyGift',
                    label: 'รับแพ็กเล็กฟรี'
                },
                {
                    value: 'CrossBossPassReward',
                    label: 'รางวัลผ่านด่านบอสข้ามเซิร์ฟเวอร์'
                },
                {
                    value: 'GetDailyRechargeDaysReward',
                    label: 'รับรางวัลจำนวนวันเติมเงินสะสมรายวัน'
                },
                {
                    value: 'BuySeaTreasureItem',
                    label: 'ค้นหาสมบัติบนเกาะ'
                },
                {
                    value: 'SeaTreasure',
                    label: 'เกาะ'
                },
                {
                    value: 'GetHeroDaysReward',
                    label: 'รับรางวัลตัวละคร 7 วัน'
                },
                {
                    value: 'GetAccumulateRechargeReward',
                    label: 'รับรางวัลเติมเงินสะสม'
                },
                {
                    value: 'CrossBossDefense',
                    label: 'ป้องกันบอสข้ามเซิร์ฟเวอร์'
                },
                {
                    value: 'DungeonFinalReward',
                    label: 'สรุปผลดันเจียน'
                },
                {
                    value: 'CrossBossRankReward',
                    label: 'รางวัลผ่านด่านบอสข้ามเซิร์ฟเวอร์'
                },
                {
                    value: 'CrossBossDungeonReward',
                    label: 'รางวัลผ่านด่านบอสข้ามเซิร์ฟเวอร์'
                },
                {
                    value: 'NewServerPromotionDaysReward',
                    label: 'รางวัลจำนวนวันโปรโมชันเซิร์ฟเวอร์ใหม่'
                },
                {
                    value: 'Garden',
                    label: 'สวนหอมกรุ่น'
                },
                {
                    value: 'DivineLove',
                    label: 'ถามรักสวรรค์และปฐพี'
                },
                {
                    value: 'BuyDivineLoveItem',
                    label: 'ซื้อไอเทมถามรักสวรรค์และปฐพี'
                },
                {
                    value: 'LuckyFlipCardCumulateReward',
                    label: 'รางวัลสะสมพลิกการ์ดนำโชค'
                },
                {
                    value: 'LuckyFlipCardReward',
                    label: 'รางวัลเปิดการ์ดนำโชค'
                },
                {
                    value: 'IslandHigh',
                    label: 'ไต่หอคอยเกาะ'
                },
                {
                    value: 'HidderWeaponHigh',
                    label: 'รางวัลอาวุธลับขั้นสูง'
                },
                {
                    value: 'SeaTreasureHigh',
                    label: 'ค้นหาสมบัติเทพสมุทรขั้นสูง'
                },
                {
                    value: 'DivineLoveHigh',
                    label: 'ถามรักสวรรค์และปฐพีขั้นสูง'
                },
                {
                    value: 'Trident',
                    label: 'ตรีศูล'
                },
                {
                    value: 'DragonBoat',
                    label: 'กิจกรรมเทศกาลตวนอู่'
                },
                {
                    value: 'DragonBoatBuyTicket',
                    label: 'ซื้อตั๋วกิจกรรมเทศกาลตวนอู่'
                },
                {
                    value: 'StoneWall',
                    label: 'กำแพงศิลาห้าวเทียน'
                },
                {
                    value: 'StoneWallHigh',
                    label: 'กำแพงศิลาห้าวเทียนขั้นสูง'
                },
                {
                    value: 'BuyStoneWallItem',
                    label: 'ซื้อไอเทมกำแพงศิลาห้าวเทียน'
                },
                {
                    value: 'IslandChallenge',
                    label: 'ท้าทายเกาะ'
                },
                {
                    value: 'CarnivalBoss',
                    label: 'บอสคาร์นิวัล'
                },
                {
                    value: 'CarnivalRecharge',
                    label: 'เติมเงินสะสมคาร์นิวัล'
                },
                {
                    value: 'TravelItemAdd',
                    label: 'ใช้ไอเทมท่องโลก'
                },
                {
                    value: 'BuyCarnivalMallGift',
                    label: 'ร้านลดราคาคาร์นิวัล'
                },
                {
                    value: 'TravelFriendAdd',
                    label: 'ใช้ไอเทมท่องโลก'
                },
                {
                    value: 'TravelBoxReward',
                    label: 'รางวัลหีบสมบัติท่องโลก'
                },
                {
                    value: 'ThemeBoss',
                    label: 'บอสธีม'
                },
                {
                    value: 'HiddenWeapon',
                    label: 'อาวุธลับ'
                }
            ]
        }
    }

function clone(value) {
  if (Array.isArray(value)) return value.map(clone)
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, clone(item)]))
  }
  return value
}

export function createAdminWords() {
  return reactive(clone(initialWords))
}
