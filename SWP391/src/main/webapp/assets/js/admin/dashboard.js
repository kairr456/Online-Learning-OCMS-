(function () {
    'use strict';

    function drawTrendChart() {
        const svg = document.getElementById('revenueRegistrationChart');
        const empty = document.getElementById('lineChartEmpty');
        if (!svg || !empty) return;

        let monthlyTrend = [];
        try {
            monthlyTrend = JSON.parse(svg.dataset.trend || '[]');
        } catch (error) {
            console.error('Could not read dashboard trend data:', error);
        }

        if (!monthlyTrend.length) {
            svg.style.display = 'none';
            empty.hidden = false;
            return;
        }

        const width = 760;
        const height = 280;
        const pad = { top: 20, right: 20, bottom: 42, left: 54 };
        const plotWidth = width - pad.left - pad.right;
        const plotHeight = height - pad.top - pad.bottom;
        const maxRevenue = Math.max(...monthlyTrend.map(point => Number(point.revenue)), 1);
        const maxRegistrations = Math.max(...monthlyTrend.map(point => Number(point.registrations)), 1);
        const x = index => pad.left + (monthlyTrend.length === 1
            ? plotWidth / 2
            : index * plotWidth / (monthlyTrend.length - 1));
        const y = (value, max) => pad.top + plotHeight - Number(value) / max * plotHeight;
        const revenueCoords = monthlyTrend.map((point, index) => [x(index), y(point.revenue, maxRevenue)]);
        const registrationCoords = monthlyTrend.map((point, index) => [x(index), y(point.registrations, maxRegistrations)]);

        const smoothPath = coords => {
            if (coords.length === 1) return 'M ' + coords[0][0] + ' ' + coords[0][1];
            let path = 'M ' + coords[0][0] + ' ' + coords[0][1];
            for (let index = 1; index < coords.length; index++) {
                const previous = coords[index - 1];
                const current = coords[index];
                const midpoint = (previous[0] + current[0]) / 2;
                path += ' C ' + midpoint + ' ' + previous[1] + ', '
                    + midpoint + ' ' + current[1] + ', '
                    + current[0] + ' ' + current[1];
            }
            return path;
        };

        const revenuePoints = revenueCoords.map(point => point.join(',')).join(' ');
        const revenueArea = pad.left + ',' + (pad.top + plotHeight) + ' '
            + revenuePoints + ' ' + x(monthlyTrend.length - 1) + ',' + (pad.top + plotHeight);
        svg.innerHTML = '<defs><linearGradient id="revenueFill" x1="0" x2="0" y1="0" y2="1">'
            + '<stop offset="0" stop-color="#D8A24A" stop-opacity=".28"/>'
            + '<stop offset="1" stop-color="#D8A24A" stop-opacity="0"/></linearGradient></defs>'
            + '<polygon class="line-area" points="' + revenueArea + '"/>'
            + '<path class="line-path line-path--revenue" d="' + smoothPath(revenueCoords) + '"/>'
            + '<path class="line-path line-path--registrations" d="' + smoothPath(registrationCoords) + '"/>';

        monthlyTrend.forEach((point, index) => {
            const revenue = Number(point.revenue).toLocaleString() + 'đ';
            const registrations = point.registrations + ' đăng ký';
            svg.insertAdjacentHTML('beforeend', '<circle class="line-point line-point--revenue" cx="'
                + revenueCoords[index][0] + '" cy="' + revenueCoords[index][1] + '" r="4"><title>'
                + point.period + ': ' + revenue + '</title></circle><circle class="line-point line-point--registrations" cx="'
                + registrationCoords[index][0] + '" cy="' + registrationCoords[index][1] + '" r="4"><title>'
                + point.period + ': ' + registrations + '</title></circle><text class="chart-label" x="'
                + x(index) + '" y="' + (height - 14) + '" text-anchor="middle">'
                + point.period + '</text>');
        });
    }

    drawTrendChart();
}());
