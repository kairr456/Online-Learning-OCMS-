/**
 * OCMS Admin Dashboard — Chart.js Charts
 * Requires Chart.js 4.x loaded globally (via admin_layout.jsp CDN script)
 */
(function () {
    'use strict';

    /* ──────────────────────────────────────────────
       THEME TOKENS (match CSS variables)
    ────────────────────────────────────────────── */
    const C = {
        amber:       '#D8A24A',
        amberLight:  'rgba(216,162,74,.15)',
        amberArea:   'rgba(216,162,74,.12)',
        blue:        '#3b82f6',
        blueLight:   'rgba(59,130,246,.12)',
        green:       '#10b981',
        orange:      '#f97316',
        purple:      '#6366f1',
        red:         '#ef4444',
        slate:       '#94a3b8',
        slateLight:  '#f1f5f9',
        ink:         '#0f172a',
        inkMid:      '#475569',
    };

    /* Status colour map for bar/pie charts */
    const STATUS_COLORS = {
        active:    C.green,
        Active:    C.green,
        inactive:  C.red,
        Inactive:  C.red,
        draft:     C.slate,
        Draft:     C.slate,
        pending:   '#f59e0b',
        Pending:   '#f59e0b',
        cancelled: '#d97706',
        Cancelled: '#d97706',
        archived:  '#334155',
        Archived:  '#334155',
    };

    /* ──────────────────────────────────────────────
       GLOBAL CHART DEFAULTS
    ────────────────────────────────────────────── */
    Chart.defaults.font.family = "'Inter', -apple-system, sans-serif";
    Chart.defaults.font.size   = 12;
    Chart.defaults.color       = C.inkMid;
    Chart.defaults.plugins.legend.display = false;
    Chart.defaults.plugins.tooltip.backgroundColor = C.ink;
    Chart.defaults.plugins.tooltip.padding         = 10;
    Chart.defaults.plugins.tooltip.cornerRadius    = 8;
    Chart.defaults.plugins.tooltip.titleColor      = '#f1f5f9';
    Chart.defaults.plugins.tooltip.bodyColor       = '#94a3b8';
    Chart.defaults.plugins.tooltip.titleFont       = { weight: '700', size: 13 };

    /* ──────────────────────────────────────────────
       1. LINE CHART — Revenue & Registrations
    ────────────────────────────────────────────── */
    function initLineChart() {
        const svgEl   = document.getElementById('revenueRegistrationChart');
        const canvasEl = document.getElementById('revenueLineChart');
        const emptyEl  = document.getElementById('lineChartEmpty');

        if (!svgEl || !canvasEl) return;

        let data = [];
        try { data = JSON.parse(svgEl.dataset.trend || '[]'); } catch (e) {}

        if (!data.length) {
            canvasEl.style.display = 'none';
            if (emptyEl) emptyEl.hidden = false;
            return;
        }

        const labels        = data.map(d => d.period);
        const revenues      = data.map(d => Number(d.revenue));
        const registrations = data.map(d => Number(d.registrations));

        const ctx = canvasEl.getContext('2d');

        /* Gradient fill for revenue area */
        const gradRev = ctx.createLinearGradient(0, 0, 0, 300);
        gradRev.addColorStop(0,   'rgba(216,162,74,.28)');
        gradRev.addColorStop(1,   'rgba(216,162,74,0)');

        const gradReg = ctx.createLinearGradient(0, 0, 0, 300);
        gradReg.addColorStop(0,   'rgba(59,130,246,.18)');
        gradReg.addColorStop(1,   'rgba(59,130,246,0)');

        new Chart(ctx, {
            type: 'line',
            data: {
                labels,
                datasets: [
                    {
                        label:           'Revenue (₫)',
                        data:            revenues,
                        borderColor:     C.amber,
                        backgroundColor: gradRev,
                        borderWidth:     2.5,
                        pointRadius:     4,
                        pointHoverRadius:6,
                        pointBackgroundColor: '#fff',
                        pointBorderColor:     C.amber,
                        pointBorderWidth:     2.5,
                        tension:         0.4,
                        fill:            true,
                        yAxisID:         'yRevenue',
                    },
                    {
                        label:           'Registrations',
                        data:            registrations,
                        borderColor:     C.blue,
                        backgroundColor: gradReg,
                        borderWidth:     2.5,
                        borderDash:      [6, 4],
                        pointRadius:     4,
                        pointHoverRadius:6,
                        pointBackgroundColor: '#fff',
                        pointBorderColor:     C.blue,
                        pointBorderWidth:     2.5,
                        tension:         0.4,
                        fill:            true,
                        yAxisID:         'yReg',
                    },
                ],
            },
            options: {
                responsive:          true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                animation:   { duration: 800, easing: 'easeOutQuart' },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function(ctx) {
                                if (ctx.datasetIndex === 0) {
                                    return ' Revenue: ' + Number(ctx.raw).toLocaleString('vi-VN') + '₫';
                                }
                                return ' Registrations: ' + ctx.raw;
                            },
                        },
                    },
                },
                scales: {
                    x: {
                        grid:  { color: '#f1f5f9' },
                        ticks: { color: C.slate, font: { size: 11 } },
                    },
                    yRevenue: {
                        position: 'left',
                        grid:  { color: '#f1f5f9' },
                        ticks: {
                            color: C.amber,
                            font:  { size: 11 },
                            callback: v => {
                                if (v >= 1_000_000) return (v / 1_000_000).toFixed(0) + 'M₫';
                                if (v >= 1_000)     return (v / 1_000).toFixed(0) + 'K₫';
                                return v + '₫';
                            },
                        },
                    },
                    yReg: {
                        position: 'right',
                        grid:  { drawOnChartArea: false },
                        ticks: { color: C.blue, font: { size: 11 } },
                    },
                },
            },
        });
    }

    /* ──────────────────────────────────────────────
       2. DOUGHNUT — Quiz Pass Rate
    ────────────────────────────────────────────── */
    function initDoughnut(canvasId, value, color) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return;

        const pct = Math.max(0, Math.min(100, Number(canvas.dataset.value || value || 0)));

        new Chart(canvas.getContext('2d'), {
            type: 'doughnut',
            data: {
                datasets: [{
                    data:            [pct, 100 - pct],
                    backgroundColor: [color, '#f1f5f9'],
                    borderWidth:     0,
                    hoverOffset:     4,
                }],
            },
            options: {
                responsive:          true,
                maintainAspectRatio: false,
                cutout:              '70%',
                animation:           { duration: 900, easing: 'easeOutQuart' },
                plugins: {
                    legend:  { display: false },
                    tooltip: {
                        callbacks: {
                            label: ctx => ctx.dataIndex === 0
                                ? ' ' + pct + '%'
                                : ' Remaining: ' + (100 - pct) + '%',
                        },
                    },
                },
            },
        });
    }

    /* ──────────────────────────────────────────────
       3. BAR CHART — Course Status
    ────────────────────────────────────────────── */
    function initBarChart() {
        const canvas = document.getElementById('courseStatusChart');
        if (!canvas) return;

        let labels = [], values = [];
        try {
            labels = JSON.parse(canvas.dataset.labels || '[]');
            values = JSON.parse(canvas.dataset.values || '[]');
        } catch (e) {}

        if (!labels.length) return;

        const backgroundColors = labels.map(l =>
            STATUS_COLORS[l] || STATUS_COLORS[l.toLowerCase()] || C.slate
        );

        new Chart(canvas.getContext('2d'), {
            type: 'bar',
            data: {
                labels,
                datasets: [{
                    label:           'Courses',
                    data:            values,
                    backgroundColor: backgroundColors.map(c => c + 'cc'), /* ~80% opacity */
                    borderColor:     backgroundColors,
                    borderWidth:     2,
                    borderRadius:    8,
                    borderSkipped:   false,
                }],
            },
            options: {
                responsive:          true,
                maintainAspectRatio: false,
                animation:           { duration: 700, easing: 'easeOutQuart' },
                plugins: {
                    legend:  { display: false },
                    tooltip: {
                        callbacks: { label: ctx => ' ' + ctx.raw + ' khóa học' },
                    },
                },
                scales: {
                    x: {
                        grid:  { display: false },
                        ticks: { color: C.inkMid, font: { size: 12, weight: '600' } },
                    },
                    y: {
                        grid:  { color: '#f1f5f9' },
                        ticks: { color: C.slate, precision: 0 },
                        beginAtZero: true,
                    },
                },
            },
        });
    }

    /* ──────────────────────────────────────────────
       INIT ALL
    ────────────────────────────────────────────── */
    function init() {
        initLineChart();
        initDoughnut('quizPassChart',   null, C.green);
        initDoughnut('lessonCompChart', null, C.purple);
        initBarChart();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

}());
