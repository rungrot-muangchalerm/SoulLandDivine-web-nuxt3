<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="magic-stick"></i>หักทรัพยากร</bs-breadcrumb-item>
                <bs-breadcrumb-item>หักไอเทม</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div v-if="loading" class="alert alert-info">กำลังโหลดรายการไอเทม...</div>
            <div v-else class="small text-body-secondary mb-2">
                {{ opt_server ? `รายการไอเทมทั้งหมด ${total} รายการ` : 'เลือกเซิร์ฟเวอร์เพื่อแสดงรายการไอเทม' }}
            </div>
            <bs-table :data="opt_params" border row-key="selectionKey" class="w-100">
                <bs-table-column prop="UserId" label="UID ผู้เล่น" align="center"></bs-table-column>
                <bs-table-column prop="CharacterName" label="ตัวละคร" align="center"></bs-table-column>
                <bs-table-column prop="ItemCategory" label="ประเภททรัพยากร" align="center"></bs-table-column>
                <bs-table-column prop="ItemUid" label="UID ทรัพยากร" align="center"></bs-table-column>
                <bs-table-column prop="ItemId" label="รหัสไอเทม" align="center"></bs-table-column>
                <bs-table-column prop="ItemNum" label="จำนวน" align="center"></bs-table-column>
                <bs-table-column prop="Year" label="ปีของวงแหวนวิญญาณ" align="center"></bs-table-column>
                <bs-table-column prop="MainNature" label="คุณสมบัติกระดูกวิญญาณ" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature1" label="คุณสมบัติเสริมกระดูกวิญญาณ 1" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature2" label="คุณสมบัติเสริมกระดูกวิญญาณ 2" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature3" label="คุณสมบัติเสริมกระดูกวิญญาณ 3" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature4" label="คุณสมบัติเสริมกระดูกวิญญาณ 4" align="center"></bs-table-column>
                <bs-table-column prop="Level" label="ระดับการเสริมพลัง" align="center"></bs-table-column>
                <bs-table-column label="การดำเนินการ" width="150" align="center">
                    <template #default="scope">
                        <bs-button type="text" @click="handleDelete(scope.$index,scope.row)" class="text-danger">ยกเลิกการเลือก</bs-button>
                        <bs-button type="text" @click="handleDeduct(scope.$index,scope.row)">หัก</bs-button>
                    </template>
                </bs-table-column>
            </bs-table>
            <br>
            <bs-table :data="tableData" border row-key="selectionKey" class="w-100">
                <bs-table-column prop="UserId" label="UID ผู้เล่น" align="center"></bs-table-column>
                <bs-table-column prop="AccountName" label="บัญชี" align="center"></bs-table-column>
                <bs-table-column prop="CharacterName" label="ตัวละคร" align="center"></bs-table-column>
                <bs-table-column prop="ItemCategory" label="ประเภททรัพยากร" align="center"></bs-table-column>
                <bs-table-column prop="ItemUid" label="UID ทรัพยากร" align="center"></bs-table-column>
                <bs-table-column prop="ItemId" label="รหัสไอเทม" align="center"></bs-table-column>
                <bs-table-column prop="ItemNum" label="จำนวน" align="center"></bs-table-column>
                <bs-table-column prop="Year" label="ปีของวงแหวนวิญญาณ" align="center"></bs-table-column>
                <bs-table-column prop="MainNature" label="คุณสมบัติกระดูกวิญญาณ" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature1" label="คุณสมบัติเสริมกระดูกวิญญาณ 1" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature2" label="คุณสมบัติเสริมกระดูกวิญญาณ 2" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature3" label="คุณสมบัติเสริมกระดูกวิญญาณ 3" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature4" label="คุณสมบัติเสริมกระดูกวิญญาณ 4" align="center"></bs-table-column>
                <bs-table-column prop="Level" label="ระดับการเสริมพลัง" align="center"></bs-table-column>
                <bs-table-column label="การดำเนินการ" width="150" align="center">
                    <template #default="scope">
                        <bs-button v-if="scope.row.CanDeduct" type="text" @click="handleChoose(scope.$index,scope.row)">เลือกหัก</bs-button>
                        <span v-else>ดูอย่างเดียว</span>
                    </template>
                </bs-table-column>
            </bs-table>
            <bs-pagination
                v-if="total > 0"
                :current-page="page"
                :page-size="pageSize"
                :total="total"
                layout="prev, pager, next, total"
                @current-change="handlePageChange"
            ></bs-pagination>
        </div>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
import { BsMessage } from '~/utils/bootstrap-message'

    export default {
        
        setup () {
            return {
                words: createAdminWords(),
                opt_server: useCookie('selectedServer', { default: () => '' })
            }
        },
        data () {
            return {
                opt_params: [],
                tableData: [],
                page: 1,
                pageSize: 50,
                total: 0,
                loading: false,
                inventoryRequestId: 0
            }
        },
        watch: {
            opt_server: {
                immediate: true,
                handler () {
                    this.page = 1;
                    this.opt_params = [];
                    this.inventoryRequestId++;
                    this.loadInventory();
                }
            }
        },
        methods: {
            handlePageChange (page) {
                this.page = page;
                this.loadInventory();
            },
            loadInventory () {
                const requestId = ++this.inventoryRequestId;
                if (!this.opt_server) {
                    this.tableData = [];
                    this.total = 0;
                    this.loading = false;
                    return;
                }
                this.loading = true;
                this.$api.post('/api/itemdelete/listServer', {
                    serverId: this.opt_server,
                    page: this.page
                }).then((res) => {
                    if (requestId !== this.inventoryRequestId) return;
                    this.tableData = res.data.data.map((item, index) => ({
                        ...item,
                        selectionKey: `${item.UserId}:${item.RewardType}:${item.ItemUid}:${index}`
                    }));
                    this.page = res.data.page;
                    this.pageSize = res.data.pageSize;
                    this.total = res.data.total;
                }).catch((err) => {
                    if (requestId === this.inventoryRequestId) {
                        BsMessage.error(err?.data?.statusMessage || 'โหลดรายการไอเทมไม่สำเร็จ');
                    }
                }).finally(() => {
                    if (requestId === this.inventoryRequestId) {
                        this.loading = false;
                    }
                });
            },
            handleChoose (index, row) {
                if (!row.CanDeduct) {
                    BsMessage.info('ข้อมูลประเภทนี้แสดงได้อย่างเดียว ยังไม่รองรับการหักจากหน้านี้');
                    return;
                }
                this.opt_params.push({ ...row });
            },
            handleDelete (index,row) {
                this.opt_params.splice(index,1);
            },
            handleDeduct (index,row) {
                const params = {
                    serverId: this.opt_server,
                    userId: row.UserId,
                    rewardType: row.RewardType,
                    itemId: row.ItemId,
                    itemUid: row.ItemUid,
                    amount: row.ItemNum
                }
                this.$api.post('/api/players/items/deduct', params)
                .then(res => {
                    if (res.data.result === 1) {
                        BsMessage.success(`หักไอเทมประเภท ${params.rewardType} รหัส ${params.itemId} จำนวน ${params.amount} ชิ้น จาก ${params.userId} สำเร็จ`);
                        this.opt_params.splice(index,1);
                        this.tableData = this.tableData.filter(item => item.selectionKey !== row.selectionKey);
                        this.total = Math.max(0, this.total - 1);
                        if (!this.tableData.length && this.page > 1) {
                            this.page -= 1;
                        }
                        this.loadInventory();
                    }
                }).catch((err) => {
                    BsMessage.error(err?.data?.statusMessage || 'หักไอเทมไม่สำเร็จ');
                });
            }
        }
    }
</script>
