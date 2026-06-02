import { mediaquery } from '@kit.ArkUI';

enum GameMode {
  SINGLE_AI = '单人挑战精明AI',
  LOCAL_DOUBLE = '双人同屏对决'
}

@Entry
@Component
struct TicTacToeFancyPlus {
  // ================= 游戏核心状态 =================
  @State board: string[] = Array(100).fill('');
  @State isXNext: boolean = true;
  @State winner: string = '';
  @State winIndices: number[] = [];
  @State gameMode: GameMode = GameMode.LOCAL_DOUBLE;
  @State moveHistory: number[] = [];
  @State highlightHistoryIndex: number = -1;

  // 动画状态
  @State winAnimationScale: number = 1.0;

  private gridSize: number = 10;
  private winCount: number = 5;

  // ================= 媒体查询状态 =================
  @State currentBreakpoint: string = 'sm';
  private smListener = mediaquery.matchMediaSync('(width < 600vp)');
  private mdListener = mediaquery.matchMediaSync('(600vp <= width < 840vp)');
  private lgListener = mediaquery.matchMediaSync('(840vp <= width)');

  aboutToAppear() {
    this.registerBreakpoint();
  }

  aboutToDisappear() {
    this.smListener.off('change');
    this.mdListener.off('change');
    this.lgListener.off('change');
  }

  registerBreakpoint() {
    this.smListener.on('change', (res) => { if (res.matches) this.currentBreakpoint = 'sm'; });
    this.mdListener.on('change', (res) => { if (res.matches) this.currentBreakpoint = 'md'; });
    this.lgListener.on('change', (res) => { if (res.matches) this.currentBreakpoint = 'lg'; });
  }

  // ================= 游戏核心算法与 AI =================
  handleClick(index: number) {
    if (this.board[index] !== '' || this.winner !== '') return;

    this.executeMove(index, this.isXNext ? 'X' : 'O');

    if (this.gameMode === GameMode.SINGLE_AI && this.winner === '' && !this.isXNext) {
      setTimeout(() => {
        this.executeAIMove();
      }, 400);
    }
  }

  executeMove(index: number, player: string) {
    animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.board[index] = player;
      this.moveHistory.push(index);
    });
    this.isXNext = !this.isXNext;
    this.checkWinner(index);
  }

  executeAIMove() {
    let bestScore = -1;
    let bestIndices: number[] = [];

    for (let i = 0; i < 100; i++) {
      if (this.board[i] !== '') continue;
      let score = this.evaluatePointScore(i);
      if (score > bestScore) {
        bestScore = score;
        bestIndices = [i];
      } else if (score === bestScore) {
        bestIndices.push(i);
      }
    }

    if (bestIndices.length === 0) return;

    let finalIndex = bestIndices[0];
    let minDistance = 100;
    bestIndices.forEach(idx => {
      let r = Math.floor(idx / this.gridSize);
      let c = idx % this.gridSize;
      let dist = Math.pow(r - 4.5, 2) + Math.pow(c - 4.5, 2);
      if (dist < minDistance) {
        minDistance = dist;
        finalIndex = idx;
      }
    });

    this.executeMove(finalIndex, 'O');
  }

  evaluatePointScore(index: number): number {
    let totalScore = 0;
    const directions = [[0, 1], [1, 0], [1, 1], [1, -1]];
    const row = Math.floor(index / this.gridSize);
    const col = index % this.gridSize;

    directions.forEach(dir => {
      totalScore += this.getLineScore(row, col, dir[0], dir[1], 'O');
      totalScore += this.getLineScore(row, col, dir[0], dir[1], 'X') * 0.9;
    });
    return totalScore;
  }

  getLineScore(row: number, col: number, dr: number, dc: number, player: string): number {
    let count = 1;
    let r = row + dr; let c = col + dc;
    while (r >= 0 && r < this.gridSize && c >= 0 && c < this.gridSize && this.board[r * this.gridSize + c] === player) { count++; r += dr; c += dc; }
    r = row - dr; c = col - dc;
    while (r >= 0 && r < this.gridSize && c >= 0 && c < this.gridSize && this.board[r * this.gridSize + c] === player) { count++; r -= dr; c -= dc; }

    if (count >= 5) return 100000;
    if (count === 4) return 10000;
    if (count === 3) return 1000;
    if (count === 2) return 100;
    return count;
  }

  checkWinner(index: number) {
    const b = this.board;
    const row = Math.floor(index / this.gridSize);
    const col = index % this.gridSize;
    const player = b[index];
    const directions = [[0, 1], [1, 0], [1, 1], [1, -1]];

    for (let i = 0; i < directions.length; i++) {
      let tempIndices = [index];
      this.collectIndices(tempIndices, row, col, directions[i][0], directions[i][1], player);
      this.collectIndices(tempIndices, row, col, -directions[i][0], -directions[i][1], player);

      if (tempIndices.length >= this.winCount) {
        this.winner = player;
        this.winIndices = tempIndices;

        animateTo({ duration: 600, tempo: 1.0, curve: Curve.Linear }, () => {
          this.winAnimationScale = 1.05;
        });
        return;
      }
    }
    if (!b.includes('')) this.winner = 'Draw';
  }

  collectIndices(list: number[], row: number, col: number, dr: number, dc: number, player: string) {
    let r = row + dr; let c = col + dc;
    while (r >= 0 && r < this.gridSize && c >= 0 && c < this.gridSize && this.board[r * this.gridSize + c] === player) {
      list.push(r * this.gridSize + c); r += dr; c += dc;
    }
  }

  resetGame() {
    this.winAnimationScale = 1.0;
    animateTo({ duration: 400, curve: Curve.EaseInOut }, () => {
      this.board = Array(100).fill('');
      this.winner = '';
      this.winIndices = [];
      this.moveHistory = [];
      this.highlightHistoryIndex = -1;
      this.isXNext = true;
    });
  }

  // ================= UI 子组件 =================

  @Builder ModeSelectorComponent() {
    Row({ space: 10 }) {
      ForEach([GameMode.LOCAL_DOUBLE, GameMode.SINGLE_AI], (mode: GameMode) => {
        Button(mode)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .height(36)
          .layoutWeight(1)
          .fontColor(this.gameMode === mode ? Color.White : '#666666')
          .backgroundColor(this.gameMode === mode ? '#2E7D32' : '#E0E0E0')
          .onClick(() => {
            this.gameMode = mode;
            this.resetGame();
          })
      })
    }
    .width('100%')
    .padding(4)
    .backgroundColor('#ECEFF1')
    .borderRadius(12)
  }

  @Builder InfoBarComponent() {
    Column({ space: 6 }) {
      Text(this.winner ? (this.winner === 'Draw' ? '🤝 平局，握手言和' : `🎉 荣耀胜者: ${this.winner}`) : `当前执子: ${this.isXNext ? '⚫ 黑方' : '⚪ 白方'}`)
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
      Text(`模式: ${this.gameMode}`).fontSize(12).fontColor('#F5F5F5').opacity(0.8)
    }
    .width('100%')
    .padding(16)
    .borderRadius(16)
    .linearGradient({
      angle: 135,
      colors: this.winner ? [['#FFD700', 0.0], ['#FFA000', 1.0]] : (this.isXNext ? [['#37474F', 0.0], ['#212121', 1.0]] : [['#FF7043', 0.0], ['#E64A19', 1.0]])
    })
    .shadow({ radius: 10, color: '#30000000', offsetY: 4 })
  }

  @Builder ChessBoardComponent() {
    Grid() {
      ForEach(this.board, (item: string, index: number) => {
        GridItem() {
          Stack() {
            // 1. 底层交叉棋盘线
            Divider().vertical(false).color('#BCAAA4').strokeWidth(1)
            Divider().vertical(true).color('#BCAAA4').strokeWidth(1)

            // 2. 顶层渲染纯圆棋子（改用 Column + borderRadius 彻底降维打击老版本 SDK 的 Circle 渲染缺陷）
            if (item === 'X') {
              // 曜石黑子
              Column()
                .width('82%')
                .height('82%')
                .borderRadius(999) // 强制裁剪包围框为正圆
                .linearGradient({
                  angle: 135,
                  colors: [['#555555', 0.0], ['#111111', 1.0]]
                })
                .shadow({ radius: 4, color: '#50000000', offsetX: 1, offsetY: 2 })
                .scale(this.winIndices.includes(index) ? { x: this.winAnimationScale, y: this.winAnimationScale } : { x: 1, y: 1 })
            } else if (item === 'O') {
              // 润泽白子
              Column()
                .width('82%')
                .height('82%')
                .borderRadius(999) // 强制裁剪包围框为正圆
                .linearGradient({
                  angle: 135,
                  colors: [['#FFFFFF', 0.0], ['#F5F5F5', 0.4], ['#D6D6D6', 1.0]]
                })
                .border({ width: 0.5, color: '#BCAAA4' }) // 防止极窄情况下边缘发虛
                .shadow({ radius: 4, color: '#35000000', offsetX: 1, offsetY: 2 })
                .scale(this.winIndices.includes(index) ? { x: this.winAnimationScale, y: this.winAnimationScale } : { x: 1, y: 1 })
            }
          }
          .width('100%')
          .aspectRatio(1)
          .backgroundColor(this.winIndices.includes(index) ? '#A5D6A7' : (this.highlightHistoryIndex === index ? '#FFF59D' : Color.Transparent))
        }
        .onClick(() => this.handleClick(index))
      })
    }
    .columnsTemplate('1fr '.repeat(10))
    .rowsTemplate('1fr '.repeat(10))
    .padding(8)
    .linearGradient({
      angle: 135,
      colors: [['#E6B875', 0.0], ['#D1A366', 1.0]]
    })
    .borderRadius(14)
    .width('100%')
    .aspectRatio(1)
    .shadow({ radius: 12, color: '#40000000', offsetY: 6 })
  }

  @Builder HistoryLogComponent() {
    Column() {
      Text('📋 棋谱行棋记录 (点击格子定位)').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#37474F').margin({ bottom: 10 })
      List({ space: 6 }) {
        ForEach(this.moveHistory, (stepIndex: number, idx: number) => {
          ListItem() {
            Row() {
              Circle().width(8).height(8).fill(idx % 2 === 0 ? Color.Black : Color.White).margin({ right: 8 })
              Text(`第 ${idx + 1} 步`).fontSize(13).fontWeight(FontWeight.Medium)
              Blank()
              Text(`坐标: [${Math.floor(stepIndex / 10) + 1}, ${stepIndex % 10 + 1}]`).fontSize(12).fontColor(Color.Gray)
            }
            .width('100%')
            .padding(10)
            .backgroundColor(this.highlightHistoryIndex === stepIndex ? '#FFF9C4' : '#FFFFFF')
            .borderRadius(6)
            .onClick(() => {
              this.highlightHistoryIndex = stepIndex;
            })
          }
        })
      }
      .width('100%')
      .height('100%')
    }
    .padding(14)
    .backgroundColor('#F4F6F7')
    .borderRadius(12)
    .layoutWeight(1)
  }

  // ================= 主布局 =================
  build() {
    Column() {
      if (this.currentBreakpoint === 'sm') {
        Column({ space: 16 }) {
          Column() { this.ModeSelectorComponent() }.margin({ top: 10 })
          this.InfoBarComponent()
          this.ChessBoardComponent()
          Blank()
          Button('🔄 擦盘重摆')
            .width('100%').height(48).fontSize(16).fontWeight(FontWeight.Bold).backgroundColor('#2E7D32')
            .onClick(() => this.resetGame())
        }
        .width('100%').height('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 16 })

      } else {
        Row({ space: 32 }) {
          Column({ space: 16 }) {
            this.ModeSelectorComponent()
            this.ChessBoardComponent()
          }
          .layoutWeight(1.2)
          .constraintSize({ maxWidth: 460 })
          .justifyContent(FlexAlign.Center)

          Column({ space: 16 }) {
            this.InfoBarComponent()
            this.HistoryLogComponent()
            Button('🔄 擦盘重摆')
              .width('100%').height(48).fontSize(16).fontWeight(FontWeight.Bold).backgroundColor('#2E7D32')
              .onClick(() => this.resetGame())
          }
          .layoutWeight(1)
          .height('100%')
          .padding({ top: 16, bottom: 16 })
        }
        .width('100%').height('100%')
        .padding(32)
      }
    }
    .width('100%').height('100%')
    .backgroundColor('#FAFAFA')
  }
}