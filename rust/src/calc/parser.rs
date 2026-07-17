// 递归下降语法分析器
// 文法（优先级从低到高）：
//   expr     := term (('+' | '-') term)*
//   term     := factor (('*' | '/') factor)*
//   factor   := percent                          // 先吃一个 factor，再看后缀 %
//   percent  := unary ('%')*                     // 连续百分号：50%% = 0.005
//   unary    := ('+' | '-') unary | primary
//   primary  := number | '(' expr ')'
//
// 一元正负号通过位置判断：当 - 处于表达式开头或紧跟 ( 、运算符时视为一元
// 这里在 unary 产生式直接消费前导 + / - 实现

use crate::calc::ast::{BinOp, Expr, UnaryOp};
use crate::calc::token::Token;

/// 解析错误
fn err(msg: &str) -> String {
    msg.to_string()
}

/// 解析 Token 序列为 AST
pub fn parse(tokens: &[Token]) -> Result<Expr, String> {
    let mut pos = 0usize;
    let expr = parse_expr(tokens, &mut pos)?;
    // 解析完成后应无剩余 token
    if pos != tokens.len() {
        return Err(err("表达式末尾有未消费的 token"));
    }
    Ok(expr)
}

// expr := term (('+' | '-') term)*
fn parse_expr(tokens: &[Token], pos: &mut usize) -> Result<Expr, String> {
    let mut left = parse_term(tokens, pos)?;
    while let Some(t) = tokens.get(*pos) {
        let op = match t {
            Token::Plus => BinOp::Add,
            Token::Minus => BinOp::Sub,
            _ => break,
        };
        *pos += 1;
        let right = parse_term(tokens, pos)?;
        left = Expr::BinOp {
            op,
            lhs: Box::new(left),
            rhs: Box::new(right),
        };
    }
    Ok(left)
}

// term := factor (('*' | '/') factor)*
fn parse_term(tokens: &[Token], pos: &mut usize) -> Result<Expr, String> {
    let mut left = parse_percent(tokens, pos)?;
    while let Some(t) = tokens.get(*pos) {
        let op = match t {
            Token::Star => BinOp::Mul,
            Token::Slash => BinOp::Div,
            _ => break,
        };
        *pos += 1;
        let right = parse_percent(tokens, pos)?;
        left = Expr::BinOp {
            op,
            lhs: Box::new(left),
            rhs: Box::new(right),
        };
    }
    Ok(left)
}

// percent := unary ('%')*
fn parse_percent(tokens: &[Token], pos: &mut usize) -> Result<Expr, String> {
    let mut node = parse_unary(tokens, pos)?;
    while let Some(Token::Percent) = tokens.get(*pos) {
        *pos += 1;
        node = Expr::Percent(Box::new(node));
    }
    Ok(node)
}

// unary := ('+' | '-') unary | primary
fn parse_unary(tokens: &[Token], pos: &mut usize) -> Result<Expr, String> {
    match tokens.get(*pos) {
        Some(Token::Plus) => {
            *pos += 1;
            let inner = parse_unary(tokens, pos)?;
            Ok(Expr::Unary {
                op: UnaryOp::Pos,
                expr: Box::new(inner),
            })
        }
        Some(Token::Minus) => {
            *pos += 1;
            let inner = parse_unary(tokens, pos)?;
            Ok(Expr::Unary {
                op: UnaryOp::Neg,
                expr: Box::new(inner),
            })
        }
        _ => parse_primary(tokens, pos),
    }
}

// primary := number | '(' expr ')'
fn parse_primary(tokens: &[Token], pos: &mut usize) -> Result<Expr, String> {
    match tokens.get(*pos) {
        Some(Token::Num(n)) => {
            let node = Expr::Num(*n);
            *pos += 1;
            Ok(node)
        }
        Some(Token::LParen) => {
            *pos += 1; // 消费 '('
            let inner = parse_expr(tokens, pos)?;
            match tokens.get(*pos) {
                Some(Token::RParen) => {
                    *pos += 1; // 消费 ')'
                    Ok(inner)
                }
                _ => Err(err("缺少右括号 ')'")),
            }
        }
        Some(Token::RParen) => Err(err("多余的右括号 ')'")),
        // 末尾或运算符出现在 primary 位置
        Some(t) => Err(format!("意外的 token：{t:?}")),
        None => Err(err("表达式不完整，缺少操作数")),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::calc::token::tokenize;

    fn parse_str(s: &str) -> Result<Expr, String> {
        let toks = tokenize(s).unwrap();
        parse(&toks)
    }

    #[test]
    fn 单数字() {
        assert_eq!(parse_str("42").unwrap(), Expr::Num(42.0));
    }

    #[test]
    fn 加减乘除() {
        // 1+2-3
        let ast = parse_str("1+2-3").unwrap();
        let expected = Expr::BinOp {
            op: BinOp::Sub,
            lhs: Box::new(Expr::BinOp {
                op: BinOp::Add,
                lhs: Box::new(Expr::Num(1.0)),
                rhs: Box::new(Expr::Num(2.0)),
            }),
            rhs: Box::new(Expr::Num(3.0)),
        };
        assert_eq!(ast, expected);
    }

    #[test]
    fn 一元负号() {
        let ast = parse_str("-5").unwrap();
        assert_eq!(
            ast,
            Expr::Unary {
                op: UnaryOp::Neg,
                expr: Box::new(Expr::Num(5.0))
            }
        );
    }

    #[test]
    fn 双重负号() {
        let ast = parse_str("--5").unwrap();
        let expected = Expr::Unary {
            op: UnaryOp::Neg,
            expr: Box::new(Expr::Unary {
                op: UnaryOp::Neg,
                expr: Box::new(Expr::Num(5.0)),
            }),
        };
        assert_eq!(ast, expected);
    }

    #[test]
    fn 括号() {
        let ast = parse_str("(1+2)").unwrap();
        let expected = Expr::BinOp {
            op: BinOp::Add,
            lhs: Box::new(Expr::Num(1.0)),
            rhs: Box::new(Expr::Num(2.0)),
        };
        assert_eq!(ast, expected);
    }

    #[test]
    fn 百分号() {
        let ast = parse_str("50%").unwrap();
        assert_eq!(ast, Expr::Percent(Box::new(Expr::Num(50.0))));
    }

    #[test]
    fn 连续百分号() {
        let ast = parse_str("50%%").unwrap();
        let expected = Expr::Percent(Box::new(Expr::Percent(Box::new(Expr::Num(50.0)))));
        assert_eq!(ast, expected);
    }

    #[test]
    fn 缺右括号报错() {
        assert!(parse_str("(1+2").is_err());
    }

    #[test]
    fn 多余右括号报错() {
        assert!(parse_str("1+2)").is_err());
    }

    #[test]
    fn 空表达式报错() {
        assert!(parse_str("").is_err());
    }

    #[test]
    fn 末尾运算符报错() {
        assert!(parse_str("1+").is_err());
    }
}
