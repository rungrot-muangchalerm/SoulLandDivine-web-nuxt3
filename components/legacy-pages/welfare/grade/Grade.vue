<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-present"></i>จัดการของรางวัล</el-breadcrumb-item>
                <el-breadcrumb-item>จัดการระดับรางวัล</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-button type="success" icon="el-icon-edit" @click="handleAdd()">เพิ่ม</el-button>
                <el-input class="uid mr10" placeholder="กรอกรหัสของรางวัล" v-model="welfare_id"></el-input>
                <el-button type="primary" icon="el-icon-search" @click="handleSearch(welfare_id)">{{ words.button.search }}</el-button>
            </div>
            <el-table :data="tableData" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="id" label="รหัสของรางวัล" align="center" width="60"></el-table-column>
                <el-table-column prop="name" label="ชื่อของรางวัล" align="center"></el-table-column>
                <el-table-column prop="firstEmail" label="ของรางวัลครั้งแรก" align="center" width=""></el-table-column>
                <el-table-column prop="fixedEmail" label="ของรางวัลประจำ" align="center" width=""></el-table-column>
                <el-table-column prop="type" label="ประเภทรอบของรางวัล" align="center" width=""></el-table-column>
                <el-table-column prop="day" label="รอบของรางวัล" align="center"></el-table-column>
                <el-table-column prop="time" label="เวลามอบของรางวัล" align="center"></el-table-column>
                <el-table-column label="การดำเนินการ" width="160" align="center">
                    <template v-if="scope.row.authorization !== '管理员'" slot-scope="scope">
                        <el-button size="mini" @click="handleChange(scope.$index, scope.row)">แก้ไข</el-button>
                        <el-button size="mini" type="danger" @click="handleDelete(scope.$index, scope.row)">ลบ</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </div>
        <!-- 弹窗 -->
        <el-dialog :title="dialogTitle" :visible.sync="dialogVisible" width="30%" :close-on-click-modal="false">
            <div class="del-dialog-cnt" v-if="this.dialogType === 'delete'">{{ dialogInfo }}</div>
            <el-form ref="form" :model="form" label-width="100px" v-if="this.dialogType === 'add' || this.dialogType === 'change'">
                <el-form-item label="รหัสของรางวัล">
                    <el-input v-model="form.welfareId" placeholder="กรอกรหัสของรางวัล โดยต้องไม่ซ้ำกัน!"></el-input>
                </el-form-item>
                <el-form-item label="ชื่อของรางวัล">
                    <el-input v-model="form.welfareName" placeholder="กรอกชื่อของรางวัล"></el-input>
                </el-form-item>
                <el-form-item label="ของรางวัลครั้งแรก">
                    <el-input v-model="form.firstWelfare" placeholder="กรอกเนื้อหาของรางวัลครั้งแรก"></el-input>
                </el-form-item>
                <el-form-item label="ของรางวัลประจำ">
                    <el-input v-model="form.normalWelfare" placeholder="กรอกเนื้อหาของรางวัลประจำ"></el-input>
                </el-form-item>
                <el-form-item label="ประเภทรอบ">
                    <el-select v-model="form.periodType" placeholder="กรุณาเลือก" :disabled="this.dialogType === 'change'" @change="listenPeriodType(form.periodType)">
                        <el-option
                            v-for="type in types"
                            :key="type.value"
                            :label="type.label"
                            :value="type.value"
                        ></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="รอบ">
                    <el-input v-model="form.period" :disabled="this.dialogType === 'change' || this.form.periodType === '1'" :placeholder="periodTip" @blur="listenPeriod(form.period)"></el-input>
                </el-form-item>
                <el-form-item label="เวลามอบรางวัล">
                    <el-input v-model="form.sendOclock" :disabled="this.dialogType === 'change'"></el-input>
                </el-form-item>
            </el-form>
            <span slot="footer" class="dialog-footer">
                <el-button @click="dialogVisible = false">ยกเลิก</el-button>
                <el-button type="primary" @click="handleConfirm()">ยืนยัน</el-button>
            </span>
        </el-dialog>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie, setCookie } from '~/utils/cookies'
    import { ElMessage } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElForm, ElFormItem, ElInput, ElOption, ElSelect, ElTable, ElTableColumn } from 'element-plus'
    import md5 from 'js-md5';

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElForm, ElFormItem, ElInput, ElOption, ElSelect, ElTable, ElTableColumn },
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                welfare_id: '',
                types: [{
                    label: 'ทุกวัน',
                    value: '1'
                },{
                    label: 'ทุกสัปดาห์',
                    value: '2'
                },{
                    label: 'ทุกเดือน',
                    value: '3'
                }],
                tableData: [],
                dialogVisible: false,
                dialogTitle: '',
                dialogType: '',
                dialogInfo: '',
                form: {
                    welfareId: '',
                    welfareName: '',
                    firstWelfare: '',
                    normalWelfare: '',
                    periodType: '',
                    period: '',
                    sendOclock: ''
                },
                periodTip: ''
            }
        },
        mounted () {
            this.handleSearch(0);
        },
        methods: {
            // 查询福利内容，传入参数id，id=0则查询全部
            handleSearch (id) {
                let welfareId = undefined;
                if (id === '') {
                    welfareId = 0;
                } else {
                    welfareId = id;
                }
                let params = {
                    channel: getCookie('channel'),
                    welfareId: welfareId
                }
                this.$api.post('/api/welfare/searchGrade', params)
                .then((res) => {
                    if (res.data.list.length === 0) {
                        ElMessage.error('ไม่พบของรางวัลนี้');
                        this.tableData = [];
                    } else {
                        let resArr = res.data.list;
                        for (let i = 0; i < resArr.length; i++) {
                            if (resArr[i].type === 1) {
                                resArr[i].type = 'ทุกวัน';
                            } else if (resArr[i].type === 2) {
                                resArr[i].type = 'ทุกสัปดาห์';
                            } else if (resArr[i].type === 3) {
                                resArr[i].type = 'ทุกเดือน';
                            }
                        }
                        this.tableData = resArr;
                    }
                }).catch(function (err) {
                    console.log('fetch faild:' + err);
                })
            },
            // 点击添加按钮时打开新增弹窗面板
            handleAdd () {
                this.dialogType = 'add';
                this.dialogTitle = 'เพิ่มระดับของรางวัล';
                this.dialogVisible = true;
                this.form = {
                    welfareId: '',
                    welfareName: '',
                    firstWelfare: '',
                    normalWelfare: '',
                    periodType: '',
                    period: '',
                    sendOclock: '',
                    channel: getCookie('channel')
                }
            },
            // 点击修改按钮时打开修改弹窗面板
            handleChange (index, row) {
                this.dialogType = 'change';
                this.dialogTitle = 'แก้ไขระดับของรางวัล';
                this.dialogVisible = true;
                this.idx = index;
                const item = this.tableData[index];
                this.form = {
                    welfareId: item.id,
                    welfareName: item.name,
                    firstWelfare: item.firstEmail,
                    normalWelfare: item.fixedEmail,
                    periodType: item.type,
                    period: item.day,
                    sendOclock: item.time,
                    channel: getCookie('channel')
                }
            },
            // 点击删除按钮时打开删除提示面板
            handleDelete (index, row) {
                this.dialogType = 'delete';
                this.dialogTitle = 'ลบระดับของรางวัล';
                this.dialogVisible = true;
                this.dialogInfo = 'การลบไม่สามารถกู้คืนได้ ยืนยันการลบหรือไม่?';
                this.idx = index;
                const item = this.tableData[index];
                this.form = {
                    welfareId: item.id,
                    channel: getCookie('channel')
                }
                
            },
            // 点击弹窗面板中的确认按钮
            handleConfirm () {
                var self = this;
                if (this.dialogType === 'add') {
                    // 新增福利
                    if (this.isEmpty(this.form) === true) {
                        if (this.checkWelfare(this.form) === true) {
                            this.$api.post('/api/welfare/addGrade', this.form)
                            .then(function (res) {
                                if (res.data.result === 1) {
                                    self.dialogVisible = false;
                                    self.handleSearch(0);
                                }
                            }).catch(function (err) {
                                console.log('fetch faild: ' + err);
                            });
                        }
                    }
                } else if (this.dialogType === 'change') {
                    // 修改福利
                    if (this.isEmpty(this.form) === true) {
                        if (this.checkWelfare(this.form) === true) {
                            this.$api.post('/api/welfare/changeGrade', this.form)
                            .then(function (res) {
                                if (res.data.result === 1) {
                                    ElMessage.success('แก้ไขระดับของรางวัลสำเร็จ!');
                                    self.dialogVisible = false;
                                    self.handleSearch(0);
                                }
                            }).catch(function (err) {
                                console.log('fetch faild: ' + err); 
                            });
                        }
                    }
                } else if (this.dialogType === 'delete') {
                    // 删除福利
                    this.$api.post('/api/welfare/deleteGrade',this.form)
                    .then(res => {
                        if (res.data.result == 1) {
                            ElMessage.success('ลบสำเร็จ');
                            self.dialogVisible = false;
                            self.handleSearch(0);
                        }
                    }).catch(function (err) {
                        console.log('fetch faild: ' + err); 
                    });
                }
            },
            // 监听固定福利周期类型
            listenPeriodType (type) {
                if (type === "1") {
                    this.form.period = 1;
                } else if (type === "2") {
                    this.periodTip = "กรอกจำนวนเต็มตั้งแต่ 1 ถึง 7";
                    this.form.period = "";
                } else if (type === "3") {
                    this.periodTip = "กรอกจำนวนเต็มตั้งแต่ 1 ถึง 30";
                    this.form.period = "";
                }
            },
            // 监听固定福利周期数值
            listenPeriod (period) {
                if (this.form.periodType === "2") {
                    if (/^[-]?\d+$/.test(period)) {
                        if (period < 1 || period > 7) {
                            ElMessage.error("กรุณากรอกจำนวนเต็มในช่วงที่ถูกต้อง!");
                            this.form.period = "";
                        }
                    } else {
                        ElMessage.error("กรุณากรอกจำนวนเต็มในช่วงที่ถูกต้อง!");
                        this.form.period = "";
                    }
                    
                } else if (this.form.periodType === "3") {
                    if (/^[-]?\d+$/.test(period)) {
                        if (period < 1 || period > 30) {
                            ElMessage.error("กรุณากรอกจำนวนเต็มในช่วงที่ถูกต้อง!");
                            this.form.period = "";
                        }
                    } else {
                        ElMessage.error("กรุณากรอกจำนวนเต็มในช่วงที่ถูกต้อง!");
                        this.form.period = "";
                    }
                } else {
                    ElMessage.error("กรุณาเลือกประเภทรอบ!");
                    this.form.period = "";
                }
            },
            // 判断传入参数属性是否有空
            isEmpty(obj) {
                for (var value in obj) {
                    if (!obj[value]) {
                        ElMessage.error("มีช่องว่างที่ยังไม่ได้กรอก กรุณากรอกข้อมูลของรางวัลให้ครบ!");
                        return false;
                    }
                }
                return true;
            },
            // 判断福利发放时间点格式是否正确
            checkWelfare(opt) {
                var regOclock = /^(([0-2][0-3])|([0-1][0-9])):[0-5][0-9]:[0-5][0-9]$/;
                if (regOclock.test(opt.sendOclock) == true) {
                    return true;
                } else {
                    ElMessage.error("รูปแบบเวลามอบรางวัลไม่ถูกต้อง!");
                    return false;
                }
            }
        }
    }
</script>

<style scoped>
    .uid {
        width: 15%;
    }
    .handle-box .el-button {
        margin-bottom: 20px;
    }
</style>
