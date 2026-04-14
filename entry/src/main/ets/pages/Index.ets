
@Entry
@Component
struct TicTacToe5x5 {
  // 1. 初始化 5x5 也就是 25 个格子的空数组
  @State board: string[] = Array(25).fill('');
  @State isXNext: boolean = true;
  @State winner: string = '';

  // 2. 检查是否有玩家获胜 (5子连线)
  checkWinner() {
    const size = 5;
    const b = this.board;

    // 检查每一行
    for (let row = 0; row < size; row++) {
      const startIndex = row * size;
      if (b[startIndex] &&
        b[startIndex] === b[startIndex + 1] &&
        b[startIndex] === b[startIndex + 2] &&
        b[startIndex] === b[startIndex + 3] &&
        b[startIndex] === b[startIndex + 4]) {
        this.winner = b[startIndex];
        return;
      }
    }

    // 检查每一列
    for (let col = 0; col < size; col++) {
      if (b[col] &&
        b[col] === b[col + size] &&
        b[col] === b[col + size * 2] &&
        b[col] === b[col + size * 3] &&
        b[col] === b[col + size * 4]) {
        this.winner = b[col];
        return;
      }
    }

    // 检查左上到右下对角线 (索引 0, 6, 12, 18, 24)
    if (b[0] && b[0] === b[6] && b[0] === b[12] && b[0] === b[18] && b[0] === b[24]) {
      this.winner = b[0];
      return;
    }

    // 检查右上到左下对角线 (索引 4, 8, 12, 16, 20)
    if (b[4] && b[4] === b[8] && b[4] === b[12] && b[4] === b[16] && b[4] === b[20]) {
      this.winner = b[4];
      return;
    }

    // 检查是否平局 (没有空位且无人获胜)
    if (!this.board.includes('')) {
      this.winner = 'Draw';
    }
  }

  // 处理格子点击事件
  handleClick(index: number) {
    if (this.board[index] !== '' || this.winner !== '') {
      return;
    }
    this.board[index] = this.isXNext ? 'X' : 'O';
    this.isXNext = !this.isXNext;
    this.checkWinner();
  }

  // 重置游戏
  resetGame() {
    this.board = Array(25).fill('');
    this.isXNext = true;
    this.winner = '';
  }

  build() {
    Column({ space: 20 }) {
      Text(this.winner ? (this.winner === 'Draw' ? '平局！' : `赢家: ${this.winner}`) : `下一步: ${this.isXNext ? 'X' : 'O'}`)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60, bottom: 10 })
        .fontColor('#333333')

      // 3. 5x5 网格棋盘
      Grid() {
        ForEach(this.board, (item: string, index: number) => {
          GridItem() {
            Text(item)
            // 字体缩小，适应变小的格子
              .fontSize(35)
              .fontWeight(FontWeight.Bolder)
              .fontColor(item === 'X' ? '#1E90FF' : '#FF4500')
              .width('100%')
              .height('100%')
              .textAlign(TextAlign.Center)
          }
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .shadow({ radius: 3, color: '#CCCCCC', offsetX: 1, offsetY: 1 })
          .onClick(() => {
            this.handleClick(index);
          })
        })
      }
      // 改为均分 5 列和 5 行
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
      .columnsGap(5)
      .rowsGap(5)
      // 稍微放大棋盘整体尺寸，防止 5x5 太拥挤
      .width(350)
      .height(350)
      .backgroundColor('#F0F0F0')
      .padding(8)
      .borderRadius(15)

      Button('重新开始')
        .fontSize(20)
        .width(180)
        .height(50)
        .backgroundColor('#4CAF50')
        .margin({ top: 30 })
        .onClick(() => {
          this.resetGame();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
    .alignItems(HorizontalAlign.Center)
  }
}