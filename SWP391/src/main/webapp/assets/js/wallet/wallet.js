/**
 * OCMS - Teacher Wallet & Payout JavaScript (wallet.js)
 * Tách biệt toàn bộ logic JavaScript xử lý giao diện ví, rút tiền, tài khoản ngân hàng và phân trang/sắp xếp
 */

// ==========================================================================
// 1. Real-time Input Sanitizers & Validators
// ==========================================================================

function handleAccountNumberInput(el) {
    el.value = el.value.replace(/\D/g, '');
    const err = document.getElementById('accNumberError');
    if (err) {
        if (el.value.length > 0 && (el.value.length < 6 || el.value.length > 20)) {
            err.innerText = "Số tài khoản ngân hàng phải từ 6 đến 20 chữ số.";
            err.style.display = "block";
            el.classList.add("is-invalid");
        } else {
            err.style.display = "none";
            el.classList.remove("is-invalid");
        }
    }
}

function handleAccountHolderInput(el) {
    el.value = el.value.replace(/[^a-zA-Z\s]/g, '').toUpperCase();
    const err = document.getElementById('accHolderError');
    if (err) {
        if (el.value.trim().length > 0 && el.value.trim().length < 3) {
            err.innerText = "Tên chủ tài khoản phải có ít nhất 3 ký tự (Viết hoa không dấu).";
            err.style.display = "block";
            el.classList.add("is-invalid");
        } else {
            err.style.display = "none";
            el.classList.remove("is-invalid");
        }
    }
}

function handleTaxCodeInput(el) {
    el.value = el.value.replace(/\D/g, '');
    const err = document.getElementById('taxCodeError');
    if (err) {
        if (el.value.length > 0 && el.value.length !== 10 && el.value.length !== 13) {
            err.innerText = "Mã số thuế cá nhân phải gồm đúng 10 hoặc 13 chữ số.";
            err.style.display = "block";
            el.classList.add("is-invalid");
        } else {
            err.style.display = "none";
            el.classList.remove("is-invalid");
        }
    }
}

// ==========================================================================
// 2. Modal & Quick Action Handlers
// ==========================================================================

function openWithdrawModal() {
    const bodyEl = document.body;
    const hasBank = bodyEl.getAttribute('data-has-bank') === 'true';

    if (!hasBank) {
        showToast("Bạn chưa liên kết tài khoản ngân hàng. Vui lòng thêm số tài khoản trước.", "error");
        const bankModalEl = document.getElementById('bankModal');
        if (bankModalEl && typeof bootstrap !== 'undefined') {
            const bankModal = bootstrap.Modal.getOrCreateInstance(bankModalEl);
            bankModal.show();
        }
        return;
    }

    const withdrawModalEl = document.getElementById('withdrawModal');
    if (withdrawModalEl && typeof bootstrap !== 'undefined') {
        const withdrawModal = bootstrap.Modal.getOrCreateInstance(withdrawModalEl);
        withdrawModal.show();
    }
}

function setQuickAmount(amount) {
    const input = document.getElementById('withdrawAmount');
    if (input) {
        input.value = amount;
        input.focus();
    }
}

function handleBankSelect(selectEl) {
    const selectedOpt = selectEl.options[selectEl.selectedIndex];
    if (selectedOpt) {
        const bankName = selectedOpt.getAttribute('data-name') || '';
        const hiddenInput = document.getElementById('bankNameHidden');
        if (hiddenInput) {
            hiddenInput.value = bankName;
        }
    }
}

function showToast(msg, type) {
    if (typeof Toastify === 'function') {
        Toastify({
            text: msg,
            duration: 4000,
            close: true,
            gravity: "top",
            position: "right",
            backgroundColor: type === "error" ? "#ef4444" : "#10b981"
        }).showToast();
    } else {
        alert(msg);
    }
}

// ==========================================================================
// 3. Tab Navigation & Table Pagination State
// ==========================================================================

let currentTxPage = 1;
let currentPoPage = 1;
const WALLET_PAGE_SIZE = 5;

function switchWalletTab(tabName) {
    const btnTx = document.getElementById('tabBtnTransactions');
    const btnPo = document.getElementById('tabBtnPayouts');
    const contentTx = document.getElementById('tabTransactionsContent');
    const contentPo = document.getElementById('tabPayoutsContent');

    if (tabName === 'transactions') {
        if (btnTx) btnTx.classList.add('active');
        if (btnPo) btnPo.classList.remove('active');
        if (contentTx) contentTx.style.display = 'block';
        if (contentPo) contentPo.style.display = 'none';
    } else {
        if (btnPo) btnPo.classList.add('active');
        if (btnTx) btnTx.classList.remove('active');
        if (contentPo) contentPo.style.display = 'block';
        if (contentTx) contentTx.style.display = 'none';
    }
    renderWalletPagination();
}

function renderWalletPagination() {
    const contentTx = document.getElementById('tabTransactionsContent');
    const isTx = contentTx && contentTx.style.display !== 'none';
    const tbody = document.querySelector(isTx ? '#tabTransactionsContent tbody' : '#tabPayoutsContent tbody');
    const rowSelector = isTx ? '.wallet-tx-row' : '.wallet-po-row';
    const rows = tbody ? Array.from(tbody.querySelectorAll(rowSelector)) : [];
    const container = document.getElementById('walletPagination');
    if (!container) return;

    if (rows.length === 0) {
        container.innerHTML = '';
        return;
    }

    const totalPages = Math.max(1, Math.ceil(rows.length / WALLET_PAGE_SIZE));
    let currentPage = isTx ? currentTxPage : currentPoPage;
    if (currentPage > totalPages) {
        currentPage = totalPages;
        if (isTx) currentTxPage = currentPage; else currentPoPage = currentPage;
    }
    if (currentPage < 1) {
        currentPage = 1;
        if (isTx) currentTxPage = 1; else currentPoPage = 1;
    }

    const startIndex = (currentPage - 1) * WALLET_PAGE_SIZE;
    const endIndex = startIndex + WALLET_PAGE_SIZE;

    rows.forEach((row, idx) => {
        if (idx >= startIndex && idx < endIndex) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });

    let html = '';

    if (totalPages > 2 && currentPage > 1) {
        html += '<button type="button" class="wallet-page-btn" onclick="setWalletPage(1)" title="Trang đầu"><i class="fa-solid fa-angles-left"></i></button>';
    }

    if (currentPage > 1) {
        html += '<button type="button" class="wallet-page-btn" onclick="setWalletPage(' + (currentPage - 1) + ')" title="Trang trước"><i class="fa-solid fa-angle-left"></i></button>';
    }

    let startPage = 1;
    let endPage = totalPages;
    if (totalPages > 7) {
        if (currentPage <= 4) {
            startPage = 1;
            endPage = 7;
        } else if (currentPage + 3 >= totalPages) {
            startPage = totalPages - 6;
            endPage = totalPages;
        } else {
            startPage = currentPage - 3;
            endPage = currentPage + 3;
        }
    }

    for (let p = startPage; p <= endPage; p++) {
        const activeClass = p === currentPage ? 'active' : '';
        html += '<button type="button" class="wallet-page-btn ' + activeClass + '" onclick="setWalletPage(' + p + ')">' + p + '</button>';
    }

    if (currentPage < totalPages) {
        html += '<button type="button" class="wallet-page-btn" onclick="setWalletPage(' + (currentPage + 1) + ')" title="Trang kế tiếp"><i class="fa-solid fa-angle-right"></i></button>';
    }

    if (totalPages > 2 && currentPage < totalPages) {
        html += '<button type="button" class="wallet-page-btn" onclick="setWalletPage(' + totalPages + ')" title="Trang cuối"><i class="fa-solid fa-angles-right"></i></button>';
    }

    container.innerHTML = html;
}

function setWalletPage(page) {
    const contentTx = document.getElementById('tabTransactionsContent');
    const isTx = contentTx && contentTx.style.display !== 'none';
    if (isTx) {
        currentTxPage = page;
    } else {
        currentPoPage = page;
    }
    renderWalletPagination();
}

// ==========================================================================
// 4. Client-side Table Sorting
// ==========================================================================

let currentSortOrder = 'newest';

function updateSortIcons(order) {
    const iconTx = document.getElementById('sortIconTx');
    const iconPo = document.getElementById('sortIconPo');
    const className = order === 'oldest'
        ? 'fa-solid fa-arrow-up-wide-short ms-1 text-primary'
        : 'fa-solid fa-arrow-down-wide-short ms-1 text-primary';
    if (iconTx) iconTx.className = className;
    if (iconPo) iconPo.className = className;
}

function sortWalletTable(tbodySelector, rowSelector, order) {
    const tbody = document.querySelector(tbodySelector);
    if (!tbody) return;
    const rows = Array.from(tbody.querySelectorAll(rowSelector));
    if (rows.length <= 1) return;

    rows.sort((a, b) => {
        const timeA = parseInt(a.getAttribute('data-timestamp') || '0', 10);
        const timeB = parseInt(b.getAttribute('data-timestamp') || '0', 10);
        return order === 'oldest' ? timeA - timeB : timeB - timeA;
    });

    rows.forEach(row => tbody.appendChild(row));
}

function handleWalletSort(order) {
    currentSortOrder = order;
    const selectEl = document.getElementById('walletSortSelect');
    if (selectEl && selectEl.value !== order) {
        selectEl.value = order;
    }

    updateSortIcons(order);
    sortWalletTable('#tabTransactionsContent tbody', '.wallet-tx-row', order);
    sortWalletTable('#tabPayoutsContent tbody', '.wallet-po-row', order);

    currentTxPage = 1;
    currentPoPage = 1;
    renderWalletPagination();

    try {
        const url = new URL(window.location);
        url.searchParams.set('sort', order);
        window.history.replaceState({}, '', url);
    } catch (e) { }
}

function toggleWalletSort() {
    const newOrder = currentSortOrder === 'newest' ? 'oldest' : 'newest';
    handleWalletSort(newOrder);
}

// ==========================================================================
// 5. DOM Initialization & Form Submit Binding
// ==========================================================================

document.addEventListener("DOMContentLoaded", function () {
    // 1. Khởi tạo thứ tự sắp xếp từ data attribute hoặc query URL
    const bodySort = document.body.getAttribute('data-sort');
    if (bodySort && (bodySort === 'oldest' || bodySort === 'newest')) {
        currentSortOrder = bodySort;
    } else {
        const urlParams = new URLSearchParams(window.location.search);
        const paramSort = urlParams.get('sort');
        if (paramSort && (paramSort === 'oldest' || paramSort === 'newest')) {
            currentSortOrder = paramSort;
        }
    }
    updateSortIcons(currentSortOrder);

    // 2. Render phân trang lần đầu
    renderWalletPagination();

    // 3. Hiển thị thông báo Toast từ session / controller qua data attribute an toàn
    const flashMsg = document.body.getAttribute('data-flash-message');
    const flashType = document.body.getAttribute('data-flash-type');
    if (flashMsg && flashMsg.trim() !== '') {
        showToast(flashMsg, flashType);
    }

    // 4. Gắn submit validation cho Bank Form
    const bankForm = document.getElementById('bankForm');
    if (bankForm) {
        bankForm.addEventListener('submit', function (e) {
            const bankCodeSelect = document.getElementById('bankCodeSelect');
            const bankCode = bankCodeSelect ? bankCodeSelect.value : '';
            const accNumberInput = document.getElementById('accountNumberInput');
            const accNumber = accNumberInput ? accNumberInput.value.trim() : '';
            const accHolderInput = document.getElementById('accountHolderInput');
            const accHolder = accHolderInput ? accHolderInput.value.trim() : '';
            const taxCodeInput = document.getElementById('taxCodeInput');
            const taxCode = taxCodeInput ? taxCodeInput.value.trim() : '';

            if (!bankCode) {
                e.preventDefault();
                showToast("Vui lòng chọn ngân hàng nhận tiền.", "error");
                return false;
            }

            if (!/^\d{6,20}$/.test(accNumber)) {
                e.preventDefault();
                showToast("Số tài khoản chỉ được chứa chữ số (từ 6 đến 20 số).", "error");
                if (accNumberInput) accNumberInput.focus();
                return false;
            }

            if (!/^[a-zA-Z\s]{3,100}$/.test(accHolder)) {
                e.preventDefault();
                showToast("Tên chủ tài khoản phải viết hoa không dấu, không chứa số hoặc ký tự đặc biệt.", "error");
                if (accHolderInput) accHolderInput.focus();
                return false;
            }

            if (taxCode && !/^\d{10}(\d{3})?$/.test(taxCode)) {
                e.preventDefault();
                showToast("Mã số thuế cá nhân phải gồm 10 hoặc 13 chữ số.", "error");
                if (taxCodeInput) taxCodeInput.focus();
                return false;
            }
        });
    }

    // 5. Gắn submit validation cho Withdraw Form
    const withdrawForm = document.getElementById('withdrawForm');
    if (withdrawForm) {
        withdrawForm.addEventListener('submit', function (e) {
            const amountInput = document.getElementById('withdrawAmount');
            if (!amountInput) return;

            const amount = Number(amountInput.value);
            const maxBalance = Number(amountInput.getAttribute('max') || 0);

            if (isNaN(amount) || amount < 100000) {
                e.preventDefault();
                showToast("Số tiền rút tối thiểu là 100.000 ₫.", "error");
                amountInput.focus();
                return false;
            }

            if (amount % 10000 !== 0) {
                e.preventDefault();
                showToast("Số tiền rút phải là bội số của 10.000 ₫.", "error");
                amountInput.focus();
                return false;
            }

            if (amount > maxBalance) {
                e.preventDefault();
                showToast("Số tiền rút không được vượt quá số dư khả dụng.", "error");
                amountInput.focus();
                return false;
            }
        });
    }
});
