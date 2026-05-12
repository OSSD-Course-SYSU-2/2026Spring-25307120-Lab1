@Entry
@Component
struct TicTacToeFancy {
  @State board: string[] = Array(100).fill('');
  @State isXNext: boolean = true;
  @State winner: string = '';
  // 记录获胜棋子的索引，用于高亮动画
  @State winIndices: number[] = [];

  private gridSize: number = 10;
  private winCount: number = 5;

  // 检查获胜算法（返回获胜棋子的所有索引）
  checkWinner(index: number) {
    const b = this.board;
    const row = Math.floor(index / this.gridSize);
    const col = index % this.gridSize;
    const player = b[index];

    const directions = [[0, 1], [1, 0], [1, 1], [1, -1]];

    for (let i = 0; i < directions.length; i++) {
      let dr = directions[i][0];
      let dc = directions[i][1];

      // 存储当前方向可能连成线的索引
      let tempIndices = [index];

      // 向两个方向搜寻并记录索引
      this.collectIndices(tempIndices, row, col, dr, dc, player);
      this.collectIndices(tempIndices, row, col, -dr, -dc, player);

      if (tempIndices.length >= this.winCount) {
        this.winner = player;
        this.winIndices = tempIndices; // 激活高亮动画
        return;
      }
    }
    if (!b.includes('')) this.winner = 'Draw';
  }

  collectIndices(list: number[], row: number, col: number, dr: number, dc: number, player: string) {
    let r = row + dr;
    let c = col + dc;
    while (r >= 0 && r < this.gridSize && c >= 0 && c < this.gridSize && this.board[r * this.gridSize + c] === player) {
      list.push(r * this.gridSize + c);
      r += dr;
      c += dc;
    }
  }

  handleClick(index: number) {
    if (this.board[index] !== '' || this.winner !== '') return;

    // 播放落子动画
    animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.board[index] = this.isXNext ? 'X' : 'O';
    })

    this.isXNext = !this.isXNext;
    this.checkWinner(index);
  }

  resetGame() {
    animateTo({ duration: 500 }, () => {
      this.board = Array(100).fill('');
      this.winner = '';
      this.winIndices = [];
      this.isXNext = true;
    })
  }

  build() {
    Stack() { // 使用堆叠布局增加层次感
      Column({ space: 20 }) {
        // 顶部信息栏，根据当前玩家变色
        Column() {
          Text(this.winner ? (this.winner === 'Draw' ? '🤝 平局' : `🎉 赢家是: ${this.winner}`) : `轮到玩家: ${this.isXNext ? 'X' : 'O'}`)
            .fontSize(24)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width('90%')
        .padding(15)
        .borderRadius(20)
        .backgroundColor(this.winner ? '#FFD700' : (this.isXNext ? '#1E90FF' : '#FF4500'))
        .margin({ top: 30 })
        .shadow({ radius: 10, color: '#40000000' })

        Grid() {
          ForEach(this.board, (item: string, index: number) => {
            GridItem() {
              Text(`${item}`)
                .fontSize(item ? 20 : 0) // 没子时不显示
                .fontWeight(FontWeight.Bolder)
                .fontColor(this.winIndices.includes(index) ? Color.White : (item === 'X' ? '#1E90FF' : '#FF4500'))
                .scale(item ? { x: 1, y: 1 } : { x: 0, y: 0 }) // 落子缩放动画
            }
            .backgroundColor(this.winIndices.includes(index) ? '#4CAF50' : Color.White) // 获胜路径变绿
            .borderRadius(4)
            .aspectRatio(1)
            .margin(1)
            .onClick(() => this.handleClick(index))
          })
        }
        .columnsTemplate('1fr '.repeat(10))
        .rowsTemplate('1fr '.repeat(10))
        .width(350)
        .height(350)
        .padding(5)
        .backgroundColor('#EEEEEE')
        .borderRadius(10)

        // 底部控制按钮
        Button('🔄 开启新对局')
          .width(220)
          .height(55)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .linearGradient({
            angle: 90,
            colors: [['#4CAF50', 0.0], ['#81C784', 1.0]]
          })
          .onClick(() => this.resetGame())
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
  }
}