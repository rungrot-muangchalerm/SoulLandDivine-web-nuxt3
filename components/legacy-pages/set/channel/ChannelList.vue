<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-present"></i> จัดการการตั้งค่า</el-breadcrumb-item>
                <el-breadcrumb-item>จัดการช่องทาง</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-button type="success" icon="el-icon-edit" @click="handleAdd()">เพิ่ม</el-button>
                <!-- <el-input class="uid mr10" placeholder="输入福利ID" v-model="welfare_id"></el-input>
                <el-button type="primary" icon="el-icon-search" @click="handleSearch(welfare_id)">{{ words.button.search }}</el-button> -->
            </div>
            <el-table :data="tableData" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="name" label="ชื่อช่องทาง" align="center"></el-table-column>
                <el-table-column prop="index" label="ดัชนี" align="center"></el-table-column>
                <el-table-column prop="ip" label="IP" align="center" width=""></el-table-column>
                <el-table-column prop="url" label="ที่อยู่ XML" align="center" width=""></el-table-column>
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
                <el-form-item label="ชื่อช่องทาง">
                    <el-input v-model="form.name" placeholder="ตัวอย่าง: 混服01[1001-1400]"></el-input>
                </el-form-item>
                <el-form-item label="ดัชนี">
                    <el-input v-model="form.index" placeholder="ตัวอย่าง: hunfu"></el-input>
                </el-form-item>
                <el-form-item label="IP">
                    <el-input v-model="form.ip" placeholder="ตัวอย่าง: 192.168.10.149"></el-input>
                </el-form-item>
                <el-form-item label="ที่อยู่ XML">
                    <el-input v-model="form.url" placeholder="ตัวอย่าง: ./server_list/test.xml"></el-input>
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
    import { ElMessage } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElForm, ElFormItem, ElInput, ElTable, ElTableColumn } from 'element-plus'
    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElForm, ElFormItem, ElInput, ElTable, ElTableColumn },
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
                                ElMessage.success('แก้ไขการตั้งค่าช่องทางสำเร็จ!');
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
                            ElMessage.success('ลบสำเร็จ');
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
                        ElMessage.error("มีช่องว่างในข้อมูลช่องทาง กรุณากรอกให้ครบถ้วน!");
                        return false;
                    }
                }
                return true;
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
