export class TrafficChartWidget {
  constructor(domOrSelector, options = {}) {
    this.chartDom =
      typeof domOrSelector === "string"
        ? document.querySelector(domOrSelector)
        : domOrSelector;

    if (!this.chartDom) {
      console.error("TrafficChartWidget: Chart DOM element not found!");
      return;
    }

    const echarts = window.echarts;
    if (!echarts) {
      console.error("TrafficChartWidget: ECharts is not loaded globally!");
      return;
    }

    this.apiEndpoint = options.apiEndpoint;
    this.myChart = echarts.init(this.chartDom);

    const metaTag = document.querySelector("meta[name='csrf-token']");
    this.csrfToken = metaTag ? metaTag.getAttribute("content") : "";

    this.myChart.setOption({
      tooltip: { trigger: "axis" },
      legend: { bottom: 0, left: 'center' },
      grid: { top: '10%', left: '5%', right: '5%', bottom: '15%', containLabel: true },

      xAxis: {
        type: "category",
        data: [],
        axisTick: { show: false },
        axisLine: { show: false },
        splitLine: { show: false }
      },
      yAxis: {
        type: "value",
        axisTick: { show: false },
        axisLine: { show: false },
        splitLine: { 
          show: true, 
          lineStyle: { color: '#f3f4f6', type: 'dashed' }
        }
      },

      series: []
    });

    window.addEventListener("resize", () => this.myChart.resize());

    this.initEvents();
  }

  initEvents() {
    this.myChart.on("brushselected", (params) => {
      if (!params.batch || params.batch.length === 0) return;

      let brushComponent = params.batch[0];
      if (brushComponent && brushComponent.selected && brushComponent.selected[0]) {
        let selectedIndices = brushComponent.selected[0].dataIndex;

        if (selectedIndices && selectedIndices.length > 0) {
          let startIndex = selectedIndices[0];
          let endIndex = selectedIndices[selectedIndices.length - 1];

          let option = this.myChart.getOption();
          let fullTimes = option.xAxis[0].data;

          let startTime = fullTimes[startIndex];
          let endTime = fullTimes[endIndex];

          if (startTime && endTime && typeof this.onZoomChange === "function") {
            this.onZoomChange({ startTime, endTime });
          }
        }
      }
    });
  }


  async loadData(period, startTime, endTime) {
    try {
      let url = `${this.apiEndpoint}?period=${period}`;
      if (startTime && endTime) {
        url += `&start_time=${encodeURIComponent(startTime)}&end_time=${encodeURIComponent(endTime)}`;
      }

      const response = await fetch(url, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken,
        },
      });
      const result = await response.json();

      if (result) {
        this.renderChart(result.traffic_data);
        if (this.onDataLoaded) {
          this.onDataLoaded(result);
        }
      }
    } catch (err) {
      console.error("Failed to fetch traffic data:", err);
    }
  }

  onBrushChange(callback) {
    this.myChart.on("brushselected", (params) => {
      if (!params.batch || params.batch.length === 0) return;

      let brushComponent = params.batch[0];
      if (!brushComponent.areas || brushComponent.areas.length === 0) return;

      let area = brushComponent.areas[0];

      if (area.coordRange && area.coordRange.length >= 2) {
        let startIndex = Math.round(area.coordRange[0]);
        let endIndex = Math.round(area.coordRange[1]);

        let option = this.myChart.getOption();
        let fullTimes = option.xAxis[0].data;

        let startTime = fullTimes[startIndex];
        let endTime = fullTimes[endIndex];

        if (startTime && endTime && typeof callback === "function") {
          callback({ startTime, endTime });
        }
      }
    });
  }

  renderChart(data) {
    if (!data || data.length === 0) {
      this.myChart.showLoading({
        text: "No data available",
        color: "transparent",
        textColor: "#9ca3af",
        maskColor: "rgba(255, 255, 255, 0.8)",
      });
      return;
    }

    const times = data.map((item) => item.time);
    const totals = data.map((item) => item.total);
    const uploads = data.map((item) => item.up);
    const downloads = data.map((item) => item.down);

    let spanHours = 24;
    if (times.length >= 2) {
      const start = new Date(times[0]).getTime();
      const end = new Date(times[times.length - 1]).getTime();
      spanHours = (end - start) / (1000 * 60 * 60);
    }

    this.myChart.setOption(
      {
        tooltip: {
          trigger: "axis",
          axisPointer: {
            type: "line",
            axis: "auto",
            snap: true,
            label: { show: false },
          },
          formatter: (params) => {
            let rawTime = params[0].axisValue;

            let displayTime = rawTime.replace("T", " ").substring(0, 16);

            let result = `<div style="font-weight: bold; margin-bottom: 4px;">${displayTime}</div>`;
            params.forEach((item) => {
              const valStr = HakkawineJS.formatBytesAdaptive(item.value);
              result += `${item.marker} ${item.seriesName}: <b>${valStr}</b><br/>`;
            });
            return result;
          },
        },

        grid: {
          top: 16,
          bottom: 16,
          left: 36,
          right: 36,
          containLabel: true,
        },

        xAxis: {
          type: "category",
          boundaryGap: false,
          data: times,
          axisLabel: {
            formatter: (value) => {
              const monthDay = value.substring(5, 10);
              const timeHourMin = value.substring(11, 16);

              if (spanHours > 48) {
                return monthDay;
              } else if (spanHours > 24) {
                return `${monthDay} ${timeHourMin}`;
              } else {
                return timeHourMin;
              }
            },
            hideOverlap: true,
            interval: (index, _) => {
              const total = times.length;

              if (total <= 8) return true;

              const step = Math.round(total / 8);

              return index % step === 0;
            },
          },
          axisTick: { alignWithLabel: true },
          axisPointer: {
            label: { show: false },
          },
        },

        yAxis: {
          type: "value",
          axisLabel: { show: false },
          axisPointer: {
            label: { show: false },
          },
        },

        // brush
        brush: {
          xAxisIndex: 0,
          brushType: "lineX",
          throttleType: "debounce",
          throttleDelay: 300,
          outOfBrush: {
            colorAlpha: 0.3
          }
        },

        // remove the icon in the upper right corner
        toolbox: {
          show: false
        },

        series: [
          {
            name: "Total",
            type: "line",
            data: totals,
            itemStyle: { color: "#fbbd23" },
            large: true,
            showSymbol: false,
            sampling: 'lttb',
          },
          {
            name: "Upload",
            type: "line",
            data: uploads,
            itemStyle: { color: "#9ca3af" },
            large: true,
            showSymbol: false,
            sampling: 'lttb',
          },
          {
            name: "Download",
            type: "line",
            data: downloads,
            itemStyle: { color: "#3abff8" },
            large: true,
            showSymbol: false,
            sampling: 'lttb',
          },
        ],
      },
      true,
    );

    // brush
    this.myChart.dispatchAction({
      type: 'takeGlobalCursor',
      key: 'brush',
      brushOption: {
        brushType: 'lineX',
        brushMode: 'single'
      }
    });
  }
}
