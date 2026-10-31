<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="present"></i> จัดการการตั้งค่า</bs-breadcrumb-item>
                <bs-breadcrumb-item>จัดการช่องทาง</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
                <bs-button type="success" @click="handleAdd()">เพิ่ม</bs-button>
                <!-- <bs-input class="uid mr10" placeholder="输入福利ID" v-model="welfare_id"></bs-input>
                <bs-button type="primary" @click="handleSearch(welfare_id)">{{ words.button.search }}</bs-button> -->
            </div>
            <bs-table :data="tableData" border ref="multipleTable" class="w-100">
                <bs-table-column prop="name" label="ชื่อช่องทาง" align="center"></bs-table-column>
                <bs-table-column prop="index" label="ดัชนี" align="center"></bs-table-column>
                <bs-table-column prop="ip" label="IP" align="center" width=""></bs-table-column>
                <bs-table-column prop="url" label="ที่อยู่ XML" align="center" width=""></bs-table-column>
                <bs-table-column label="การดำเนินการ" width="160" align="center">
                    <template v-if="scope.row.authorization !== '管理员'" #default="scope">
                        <bs-button size="small" @click="handleChange(scope.$index, scope.row)">แก้ไข</bs-button>
                        <bs-button size="small" type="danger" @click="handleDelete(scope.$index, scope.row)">ลบ</bs-button>
                    </template>
                </bs-table-column>
            </bs-table>
        </div>
        <!-- 弹窗 -->
        <bs-dialog :title="dialogTitle" v-model:visible="dialogVisible" width="30%" :close-on-click-modal="false">
            <div class="del-dialog-cnt" v-if="this.dialogType === 'delete'">{{ dialogInfo }}</div>
            <bs-form ref="form" :model="form" label-width="100px" v-if="this.dialogType === 'add' || this.dialogType === 'change'">
                <bs-form-item label="ชื่อช่องทาง">
                    <bs-input v-model="form.name" placeholder="ตัวอย่าง: 混服01[1001-1400]"></bs-input>
                </bs-form-item>
                <bs-form-item label="ดัชนี">
                    <bs-input v-model="form.index" placeholder="ตัวอย่าง: hunfu"></bs-input>
                </bs-form-item>
                <bs-form-item label="IP">
                    <bs-input v-model="form.ip" placeholder="ตัวอย่าง: 192.168.10.149"></bs-input>
                </bs-form-item>
                <bs-form-item label="ที่อยู่ XML">
                    <bs-input v-model="form.url" placeholder="ตัวอย่าง: ./server_list/test.xml"></bs-input>
                </bs-form-item>
            </bs-form>
            <template #footer><div class="d-flex justify-content-end gap-2">
                <bs-button @click="dialogVisible = false">ยกเลิก</bs-button>
                <bs-button type="primary" @click="handleConfirm()">ยืนยัน</bs-button>
            </div></template>
        </bs-dialog>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
import { BsMessage } from '~/utils/bootstrap-message'
    export default {
        
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                tableData: [],
                dialogVisible: false,
                dialogTitle: '',
                dialogType: '',
                dialogInfo: '',
                form: {
                    name: '',
                    index: '',
                    ip: '',
                    url: ''
                }
            }
        },
        mounted () {
            this.handleSearch();
        },
        methods: {
            // 查询渠道配置信息
            handleSearch () {
                this.$api.post('/api/set/manageChannels')
                .then((res) => {
                    this.tableData = res.data;
                }).catch(function (err) {
                    console.log('fetch faild:' + err);
                })
            },
            // 点击添加按钮时打开新增弹窗面板
            handleAdd () {
                this.dialogType = 'add';
                this.dialogTitle = 'เพิ่มช่องทาง';
                this.dialogVisible = true;
                this.form = {
                    name: '',
                    ip: '',
                    index: '',
                    url: ''
                }
            },
            // 点击修改按钮时打开修改弹窗面板
            handleChange (index, row) {
                this.dialogType = 'change';
                this.dialogTitle = 'แก้ไขช่องทาง';
                this.dialogVisible = true;
                this.form = {
                    id: row.id,
                    name: row.name,
                    index: row.index,
                    ip: row.ip,
                    url: row.url
                }
            },
            // 点击删除按钮时打开删除提示面板
            handleDelete (index, row) {
                this.dialogType = 'delete';
                this.dialogTitle = 'ลบการตั้งค่าช่องทาง';
                this.dialogVisible = true;
                this.dialogInfo = 'การลบไม่สามารถกู้คืนได้ ต้องการลบหรือไม่?';
                this.form = {
                    id: row.id
                }
                
            },
            // 点击弹窗面板中的确认按钮
            handleConfirm () {
                var self = this;
                if (this.dialogType === 'add') {
                    // 新增渠道
                    if (this.isEmpty(this.form) === true) {
                        this.$api.post('/api/set/addChannel', this.form)
                        .then(function (res) {
                            if (res.data.result === 1) {
                                self.dialogVisible = false;
                                self.handleSearch();
                            }
                        }).catch(function (err) {
                            console.log('fetch faild: ' + err);
                        });
                    }
                } else if (this.dialogType === 'change') {
                    // 修改渠道
                    if (this.isEmpty(this.form) === true) {
                        this.$api.post('/api/set/changeChannel', this.form)
                        .then(function (res) {
                            if (res.data[0] === 1) {
                                BsMessage.success('แก้ไขการตั้งค่าช่องทางสำเร็จ!');
                                self.dialogVisible = false;
                                self.handleSearch();
                            }
                        }).catch(function (err) {
                            console.log('fetch faild: ' + err); 
                        });
                    }
                } else if (this.dialogType === 'delete') {
                    // 删除福利
                    this.$api.post('/api/set/deleteChannel',this.form)
                    .then(res => {
                        if (res.data == 1) {
                            BsMessage.success('ลบสำเร็จ');
                            self.dialogVisible = false;
                            self.handleSearch();
                        }
                    }).catch(function (err) {
                        console.log('fetch faild: ' + err); 
                    });
                }
            },
            // 判断传入参数属性是否有空
            isEmpty(obj) {
                for (var value in obj) {
                    if (!obj[value]) {
                        BsMessage.error("มีช่องว่างในข้อมูลช่องทาง กรุณากรอกให้ครบถ้วน!");
                        return false;
                    }
                }
                return true;
            }
        }
    }
</script>


