<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-setting"></i> จัดการสิทธิ์</el-breadcrumb-item>
                <el-breadcrumb-item>จัดการผู้ใช้</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-button type="success" icon="el-icon-edit" @click="handleAdd">เพิ่ม</el-button>
            </div>
            <el-table :data="tableData" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="id" label="รหัสผู้ใช้" align="center" width="90"></el-table-column>
                <el-table-column prop="username" label="ชื่อผู้ใช้" align="center" width="100"></el-table-column>
                <el-table-column prop="authorization" label="สิทธิ์" align="center"></el-table-column>
                <el-table-column prop="channel" label="ช่องทาง" align="center"></el-table-column>
                <el-table-column label="การดำเนินการ" width="250" align="center">
                    <template slot-scope="scope">
                        <el-button size="mini" @click="handleChange(scope.$index, scope.row)">แก้ไข</el-button>
                        <el-button @click="handleReset(scope.$index,scope.row)" size="mini" type="warning">รีเซ็ตรหัสผ่าน</el-button>
                        <el-button size="mini" type="danger" @click="handleDelete(scope.$index, scope.row)" v-if="scope.row.authorization !== 'Lv.admin'">ลบ</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </div>
        <!-- 弹窗 -->
        <el-dialog :title="dialogTitle" :visible.sync="dialogVisible" width="30%" :close-on-click-modal="false">
            <div class="del-dialog-cnt" v-if="this.dialogType === 'reset' || this.dialogType === 'delete'">{{ dialogInfo }}</div>
            <el-form ref="form" :model="form" label-width="60px" v-if="this.dialogType === 'add' || this.dialogType === 'change'">
                <el-form-item label="ชื่อผู้ใช้">
                    <el-input v-model="form.username" placeholder="ห้ามใช้ตัวอักษรจีนในชื่อผู้ใช้" :disabled="this.dialogType === 'change'"></el-input>
                </el-form-item>
                <el-form-item label="รหัสผ่าน" v-if="this.dialogType === 'add'">
                    <el-input v-model="form.password" :disabled="true" type="password"></el-input>
                </el-form-item>
                <el-form-item label="สิทธิ์">
                    <el-select v-model="form.authorization" placeholder="กรุณาเลือก" :disabled="form.authorization === 'Lv.admin'">
                        <el-option
                            v-for="limit in limits"
                            :key="limit"
                            :label="'Lv.' + limit"
                            :value="limit"
                        ></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="ช่องทาง">
                    <el-checkbox v-model="checkAll" @change="(val) => {form.checkedChannels = val ? channelValue : []}">เลือกทั้งหมด</el-checkbox>
                    <el-checkbox-group v-model="form.checkedChannels" @change="(val) => {checkAll = (val.length === channelValue.length)}">
                        <el-checkbox
                            v-for="item in channellist"
                            :label="item.index"
                            :key="item.index"
                            style="width: 23%"
                        >{{ item.name }}</el-checkbox>
                    </el-checkbox-group>
                </el-form-item>
            </el-form>
            <span slot="footer" class="dialog-footer">
                <el-button @click="dialogVisible = false">ยกเลิก</el-button>
                <el-button type="primary" @click="handleConfirm">ยืนยัน</el-button>
            </span>
        </el-dialog>
    </div>
</template>

<script>
    import { ElMessage } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElCheckbox, ElCheckboxGroup, ElDialog, ElForm, ElFormItem, ElInput, ElOption, ElSelect, ElTable, ElTableColumn } from 'element-plus'
    import md5 from 'js-md5';

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElCheckbox, ElCheckboxGroup, ElDialog, ElForm, ElFormItem, ElInput, ElOption, ElSelect, ElTable, ElTableColumn },
        data () {
            return {
                limits: ['server',0,1,2,3,4],
                tableData: [],
                dialogVisible: false,
                dialogTitle: '',
                dialogType: '',
                dialogInfo: '',
                form: {
                    id: '',
                    username: '',
                    password: '',
                    authorization: '',
                    checkedChannels: []
                },
                channellist: [],
                channelValue: [],
                checkAll: false
            }
        },
        mounted () {
            this.searchAll();
            this.searchChannel();
        },
        methods: {
            // 获取渠道列表
            searchChannel () {
                this.$api.post('/api/set/searchChannel')
                .then((res) => {
                    this.channellist = res.data;
                    this.channelValue = this.channellist.map((currentValue) => {return currentValue.index});
                }).catch(function (err) {
                    console.log('fetch faild:' + err);
                })
            },
            // 查询所有用户
            searchAll () {
                this.$api.post('/api/users/searchall')
                .then((res)=> {
                    for (var i=0; i<res.data.length; i++) {
                        res.data[i].authorization ='Lv.' + res.data[i].authorization;
                    }
                    this.tableData = res.data;
                }).catch(function (err) {
                    console.log('fetch faild: ' + err);
                });
            },
            // 打开新增面板
            handleAdd () {
                this.dialogType = 'add';
                this.dialogTitle = 'เพิ่มผู้ใช้';
                this.dialogVisible = true;
                this.form = {
                    username: '',
                    password: '123456',
                    authorization: '',
                    checkedChannels: []
                };
                this.checkAll = false
            },
            // 打开修改面板
            handleChange (index, row) {
                this.idx = index;
                const item = this.tableData[index];
                this.form = {
                    id: item.id,
                    username: item.username,
                    authorization: item.authorization,
                    checkedChannels: item.channel.split(',')
                }
                this.dialogType = 'change';
                this.dialogTitle = 'แก้ไขผู้ใช้';
                this.dialogVisible = true;
                if (this.form.checkedChannels.length === this.channelValue.length) {
                    this.checkAll = true;
                }
            },
            // 打开重置密码面板
            handleReset (index, row) {
                this.currentRow = row;
                this.dialogType = 'reset';
                this.dialogTitle = 'รีเซ็ตรหัสผ่าน';
                this.dialogInfo = 'รหัสผ่านของผู้ใช้จะถูกคืนค่าเป็นรหัสผ่านเริ่มต้น ต้องการดำเนินการต่อหรือไม่?';
                this.dialogVisible = true;
            },
            // 打开删除面板
            handleDelete (index, row) {
                this.idx = index;
                this.dialogType = 'delete';
                this.dialogTitle = 'ลบผู้ใช้';
                this.dialogInfo = 'การลบไม่สามารถกู้คืนได้ ต้องการลบหรือไม่?';
                this.dialogVisible = true;
            },
            // 弹窗确认按钮点击
            handleConfirm () {
                var self = this;
                if (this.dialogType === 'add') {// 新增用户
                    if (this.form.username === "" || this.form.authorization === "" || this.form.checkedChannels.length === 0) {
                        ElMessage.error('กรุณากรอกข้อมูลผู้ใช้ให้ครบถ้วน');
                    } else {
                        var params = {
                            username: this.form.username,
                            password: md5(this.form.username + this.form.password),
                            authorization: this.form.authorization,
                            channel: this.form.checkedChannels.toString()
                        }
                        this.$api.post('/api/users/add', params)
                        .then(function (res) {
                            if (res.data.result === 'success') {
                                self.dialogVisible = false;
                                self.searchAll();
                            }
                        }).catch(function (err) {
                            console.log('fetch faild: ' + err);
                        });
                    }
                } else if (this.dialogType === 'change') {// 修改用户
                    if (this.form.checkedChannels.length === 0) {
                        ElMessage.error('กรุณาเลือกช่องทางอย่างน้อยหนึ่งช่องทาง');
                    } else {
                        let params ={
                            id: this.form.id,
                            username: this.form.username,
                            authorization: this.form.authorization.slice(3),
                            channel: this.form.checkedChannels.toString()
                        }
                        this.$api.post('/api/users/change', params)
                        .then(function (res) {
                            if (res.data[0] === 1) {
                                ElMessage.success('แก้ไขข้อมูลผู้ใช้สำเร็จ!');
                                self.dialogVisible = false;
                                self.searchAll();
                            } else if (res.data[0] === 0) {
                                ElMessage.info('ไม่มีการเปลี่ยนแปลงใดๆ!');
                                self.dialogVisible = false;
                            }
                        }).catch(function (err) {
                            console.log('fetch faild: ' + err); 
                        });
                    }
                } else if (this.dialogType === 'reset') {// 重置密码
                    var params ={
                        id: this.currentRow.id,
                        password: md5(this.currentRow.username + '123456')
                    }
                    this.$api.post('/api/users/resetPass', params)
                    .then(function (res) {
                        if(res.data[0] === 1 || res.data[0] === 0){
                            ElMessage.success('รีเซ็ตรหัสผ่านสำเร็จ!');
                            self.dialogVisible = false;
                            self.searchAll();
                        }
                    }).catch(function (err) {
                        console.log('fetch faild: ' + err); 
                    });
                } else if (this.dialogType === 'delete') {// 删除用户
                    var params = {
                        id: this.tableData[this.idx].id
                    }
                    this.$api.post('/api/users/delete',params)
                    .then(res => {
                        if (res.data == 1) {
                            ElMessage.success('ลบสำเร็จ');
                            self.dialogVisible = false;
                            self.searchAll();
                        }
                    }).catch(function (err) {
                        console.log('fetch faild: ' + err); 
                    });
                }
            }
        }
    }
</script>

<style scoped>
    .handle-box .el-button {
        margin-bottom: 20px;
    }
</style>
