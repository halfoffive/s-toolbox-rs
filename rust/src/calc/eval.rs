// AST 求值：对 Expr 递归折叠
// 纯函数 eval(&Expr) -> Result<f64, String>，无副作用

use crate::calc::ast::{BinOp, Expr, UnaryOp};

/// 对 AST 求值
pub fn eval(expr: &Expr) -> Result<f64, String> {
    match expr {
        Expr::Num(n) => Ok(*n),
        Expr::Unary { op, expr } => {
            let v = eval(expr)?;
            Ok(match op {
                UnaryOp::Pos => v,
                UnaryOp::Neg => -v,
            })
        }
        Expr::BinOp { op, lhs, rhs } => {
            let l = eval(lhs)?;
            let r = eval(rhs)?;
            match op {
                BinOp::Add => Ok(l + r),
                BinOp::Sub => Ok(l - r),
                BinOp::Mul => Ok(l * r),
                BinOp::Div => {
                    if r == 0.0 {
                        Err("除零错误".to_string())
                    } else {
                        Ok(l / r)
                    }
                }
            }
        }
        Expr::Percent(inner) => Ok(eval(inner)? / 100.0),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::calc::parser::parse;
    use crate::calc::token::tokenize;

    fn eval_str(s: &str) -> Result<f64, String> {
        let toks = tokenize(s)?;
        let ast = parse(&toks)?;
        eval(&ast)
    }

    #[test]
    fn 基础四则() {
        assert_eq!(eval_str("1+2").unwrap(), 3.0);
        assert_eq!(eval_str("10-4").unwrap(), 6.0);
        assert_eq!(eval_str("6*7").unwrap(), 42.0);
        assert_eq!(eval_str("8/2").unwrap(), 4.0);
    }

    #[test]
    fn 优先级() {
        // 1+2*3 = 7
        assert_eq!(eval_str("1+2*3").unwrap(), 7.0);
        // (1+2)*3 = 9
        assert_eq!(eval_str("(1+2)*3").unwrap(), 9.0);
    }

    #[test]
    fn 一元负号() {
        assert_eq!(eval_str("-5").unwrap(), -5.0);
        assert_eq!(eval_str("3*-2").unwrap(), -6.0);
        assert_eq!(eval_str("--5").unwrap(), 5.0);
    }

    #[test]
    fn 百分号后缀() {
        // 50% = 0.5
        assert!((eval_str("50%").unwrap() - 0.5).abs() < 1e-9);
        // 200*10% = 200*0.1 = 20
        assert!((eval_str("200*10%").unwrap() - 20.0).abs() < 1e-9);
        // 50%% = 0.005
        assert!((eval_str("50%%").unwrap() - 0.005).abs() < 1e-9);
    }

    #[test]
    fn 除零错误() {
        assert!(eval_str("1/0").is_err());
    }

    #[test]
    fn 复合表达式() {
        // 12 + 3 * 4 - (2 + 6) / 2 = 12 + 12 - 4 = 20
        assert!((eval_str("12+3*4-(2+6)/2").unwrap() - 20.0).abs() < 1e-9);
    }

    #[test]
    fn 浮点运算() {
        assert!((eval_str("2.5*2").unwrap() - 5.0).abs() < 1e-9);
    }
}
