// AST 定义：不可变、用枚举表达
// 树状结构天然递归，便于 eval 模式匹配折叠

/// 表达式抽象语法树
#[derive(Debug, Clone, PartialEq)]
pub enum Expr {
    /// 数字字面量
    Num(f64),
    /// 二元运算：op(左, 右)
    BinOp {
        op: BinOp,
        lhs: Box<Expr>,
        rhs: Box<Expr>,
    },
    /// 前缀单目：一元正号 / 一元负号
    Unary { op: UnaryOp, expr: Box<Expr> },
    /// 后缀百分号：值 / 100
    Percent(Box<Expr>),
}

/// 二元运算符
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum BinOp {
    Add, // +
    Sub, // -
    Mul, // *
    Div, // /
}

/// 一元前缀运算符
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum UnaryOp {
    Pos, // +x（语义上等于 x，保留以保持 AST 完整性）
    Neg, // -x
}
