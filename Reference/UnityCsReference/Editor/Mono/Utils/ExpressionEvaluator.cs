// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using System.Collections.Generic;
using System.Globalization;

namespace UnityEditor
{
    // Evaluates simple expressions, supports int & float and operators: + - * / % ^ ( )
    public class ExpressionEvaluator
    {
        private readonly static Operator[] s_Operators =
        {
            new Operator('-', 2, 2, Associativity.Left),
            new Operator('+', 2, 2, Associativity.Left),
            new Operator('/', 3, 2, Associativity.Left),
            new Operator('*', 3, 2, Associativity.Left),
            new Operator('%', 3, 2, Associativity.Left),
            new Operator('^', 4, 2, Associativity.Right),
            new Operator('u', 4, 1, Associativity.Left) // unary minus trick. For example we convert 2/-7+(-9*8)*2^-9-5 to 2/u7+(u9*8)*2^u9-5 before evaluation
        };

        private enum Associativity { Left, Right }

        private struct Operator
        {
            public char character;
            public int presedence;
            public Associativity associativity;
            public int inputs;

            public Operator(char character, int presedence, int inputs, Associativity associativity)
            {
                this.character = character;
                this.presedence = presedence;
                this.inputs = inputs;
                this.associativity = associativity;
            }
        }

        public static bool Evaluate<T>(string expression, out T value)
        {
            if (TryParse(expression, out value))
                return true;

            expression = PreFormatExpression(expression);
            string[] infixTokens = ExpressionToTokens(expression);
            infixTokens = FixUnaryOperators(infixTokens);
            string[] RPNTokens = InfixToRPN(infixTokens);
            return Evaluate(RPNTokens, out value);
        }

        // Evaluate RPN tokens (http://en.wikipedia.org/wiki/Reverse_Polish_notation)
        private static bool Evaluate<T>(string[] tokens, out T value)
        {
            Stack<string> stack = new Stack<string>();

            foreach (string token in tokens)
            {
                if (IsOperator(token))
                {
                    Operator oper = CharToOperator(token[0]);
                    List<T> values = new List<T>();
                    bool parsed = true;

                    while (stack.Count > 0 && !IsCommand(stack.Peek()) && values.Count < oper.inputs)
                    {
                        T newValue;
                        parsed &= TryParse<T>(stack.Pop(), out newValue);
                        values.Add(newValue);
                    }

                    values.Reverse();

                    if (parsed && values.Count == oper.inputs)
                        stack.Push(Evaluate<T>(values.ToArray(), token[0]).ToString());
                    else // Can't parse values or too few values for the operator -> exit
                    {
                        value = default(T);
                        return false;
                    }
                }
                else
                {
                    stack.Push(token);
                }
            }

            if (stack.Count == 1)
            {
                if (TryParse(stack.Pop(), out value))
                    return true;
            }

            value = default(T);
            return false;
        }

        // Translate tokens from infix into RPN (http://en.wikipedia.org/wiki/Shunting-yard_algorithm)
        private static string[] InfixToRPN(string[] tokens)
        {
            Stack<char> operatorStack = new Stack<char>();
            Queue<string> outputQueue = new Queue<string>();

            foreach (string token in tokens)
            {
                if (IsCommand(token))
                {
                    char command = token[0];

                    if (command == '(') // Bracket open
                    {
                        operatorStack.Push(command);
                    }
                    else if (command == ')') // Bracket close
                    {
                        while (operatorStack.Count > 0 && operatorStack.Peek() != '(')
                            outputQueue.Enqueue(operatorStack.Pop().ToString());

                        if (operatorStack.Count > 0)
                            operatorStack.Pop();
                    }
                    else // All the other operators
                    {
                        Operator o = CharToOperator(command);

                        while (NeedToPop(operatorStack, o))
                            outputQueue.Enqueue(operatorStack.Pop().ToString());

                        operatorStack.Push(command);
                    }
                }
                else // Not a command, just a regular number
                {
                    outputQueue.Enqueue(token);
                }
            }
            while (operatorStack.Count > 0)
                outputQueue.Enqueue(operatorStack.Pop().ToString());

            return outputQueue.ToArray();
        }

        // While there is an operator (topOfStack) at the top of the operators stack and
        // either (newOperator) is left-associative and its precedence is less or equal to that of (topOfStack), or
        // (newOperator) is right-associative and its precedence is less than (topOfStack)
        private static bool NeedToPop(Stack<char> operatorStack, Operator newOperator)
        {
            if (operatorStack.Count > 0)
            {
                Operator topOfStack = CharToOperator(operatorStack.Peek());

                if (IsOperator(topOfStack.character))
                {
                    if (newOperator.associativity == Associativity.Left && newOperator.presedence <= topOfStack.presedence ||
                        newOperator.associativity == Associativity.Right && newOperator.presedence < topOfStack.presedence)
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        // Splits expression to meaningful tokens
        private static string[] ExpressionToTokens(string expression)
        {
            List<string> result = new List<string>();
            string currentString = "";

            for (int c = 0; c < expression.Length; c++)
            {
                char currentChar = expression[c];
                if (IsCommand(currentChar))
                {
                    if (currentString.Length > 0)
                        result.Add(currentString);

                    result.Add(currentChar.ToString());
                    currentString = "";
                }
                else
                {
                    if (currentChar != ' ')
                        currentString += currentChar;
                }
            }

            if (currentString.Length > 0)
                result.Add(currentString);

            return result.ToArray();
        }

        private static bool IsCommand(string token)
        {
            if (token.Length != 1)
                return false;

            return IsCommand(token[0]);
        }

        private static bool IsCommand(char character)
        {
            if (character == '(' || character == ')')
                return true;

            return IsOperator(character);
        }

        private static bool IsOperator(string token)
        {
            if (token.Length != 1)
                return false;

            return IsOperator(token[0]);
        }

        private static bool IsOperator(char character)
        {
            foreach (Operator o in s_Operators)
                if (o.character == character)
                    return true;

            return false;
        }

        private static Operator CharToOperator(char character)
        {
            foreach (Operator o in s_Operators)
                if (o.character == character)
                    return o;

            return new Operator();
        }

        // Clean up the expression before any parsing
        private static string PreFormatExpression(string expression)
        {
            string result = expression;
            result = result.Trim();

            if (result.Length == 0)
                return result;

            char lastChar = result[result.Length - 1];

            // remove trailing operator for niceness (user is middle of typing, and we don't want to evaluate to zero)
            if (IsOperator(lastChar))
                result = result.TrimEnd(lastChar);

            return result;
        }

        // Turn unary minus into an operator. For example: - ( 1 - 2 ) * - 3 becomes: u ( 1 - 2 ) * u 3
        private static string[] FixUnaryOperators(string[] tokens)
        {
            if (tokens.Length == 0)
                return tokens;

            if (tokens[0] == "-")
                tokens[0] = "u";

            for (int i = 1; i < tokens.Length - 1; i++)
            {
                string token = tokens[i];
                string previousToken = tokens[i - 1];
                string nextToken = tokens[i - 1];

                if (token == "-" && (IsCommand(previousToken) || nextToken == "(" || nextToken == ")"))
                    tokens[i] = "u";
            }
            return tokens;
        }

        // According to internetz, there are many bad ways to do arithmetics with generics. This is one of them.
        private static T Evaluate<T>(T[] values, char oper)
        {
            if (typeof(T) == typeof(float))
            {
                if (values.Length == 1)
                {
                    switch (oper)
                    {
                        case 'u':
                            return (T)(object)((float)(object)values[0] * -1.0f);
                    }
                }
                else if (values.Length == 2)
                {
                    switch (oper)
                    {
                        case '+':
                            return (T)(object)((float)(object)values[0] + (float)(object)values[1]);
                        case '-':
                            return (T)(object)((float)(object)values[0] - (float)(object)values[1]);
                        case '*':
                            return (T)(object)((float)(object)values[0] * (float)(object)values[1]);
                        case '/':
                            return (T)(object)((float)(object)values[0] / (float)(object)values[1]);
                        case '%':
                            return (T)(object)((float)(object)values[0] % (float)(object)values[1]);
                        case '^':
                            return (T)(object)UnityEngine.Mathf.Pow((float)(object)values[0], (float)(object)values[1]);
                    }
                }
            }
            else if (typeof(T) == typeof(int))
            {
                if (values.Length == 1)
                {
                    switch (oper)
                    {
                        case 'u':
                            return (T)(object)((int)(object)values[0] * -1);
                    }
                }
                else if (values.Length == 2)
                {
                    switch (oper)
                    {
                        case '+':
                            return (T)(object)((int)(object)values[0] + (int)(object)values[1]);
                        case '-':
                            return (T)(object)((int)(object)values[0] - (int)(object)values[1]);
                        case '*':
                            return (T)(object)((int)(object)values[0] * (int)(object)values[1]);
                        case '/':
                            return (T)(object)((int)(object)values[0] / (int)(object)values[1]);
                        case '%':
                            return (T)(object)((int)(object)values[0] % (int)(object)values[1]);
                        case '^':
                            return (T)(object)(int)Math.Pow((int)(object)values[0], (int)(object)values[1]);
                    }
                }
            }
            if (typeof(T) == typeof(double))
            {
                if (values.Length == 1)
                {
                    switch (oper)
                    {
                        case 'u':
                            return (T)(object)((double)(object)values[0] * -1.0f);
                    }
                }
                else if (values.Length == 2)
                {
                    switch (oper)
                    {
                        case '+':
                            return (T)(object)((double)(object)values[0] + (double)(object)values[1]);
                        case '-':
                            return (T)(object)((double)(object)values[0] - (double)(object)values[1]);
                        case '*':
                            return (T)(object)((double)(object)values[0] * (double)(object)values[1]);
                        case '/':
                            return (T)(object)((double)(object)values[0] / (double)(object)values[1]);
                        case '%':
                            return (T)(object)((double)(object)values[0] % (double)(object)values[1]);
                        case '^':
                            return (T)(object)System.Math.Pow((double)(object)values[0], (double)(object)values[1]);
                    }
                }
            }
            else if (typeof(T) == typeof(long))
            {
                if (values.Length == 1)
                {
                    switch (oper)
                    {
                        case 'u':
                            return (T)(object)((long)(object)values[0] * -1);
                    }
                }
                else if (values.Length == 2)
                {
                    switch (oper)
                    {
                        case '+':
                            return (T)(object)((long)(object)values[0] + (long)(object)values[1]);
                        case '-':
                            return (T)(object)((long)(object)values[0] - (long)(object)values[1]);
                        case '*':
                            return (T)(object)((long)(object)values[0] * (long)(object)values[1]);
                        case '/':
                            return (T)(object)((long)(object)values[0] / (long)(object)values[1]);
                        case '%':
                            return (T)(object)((long)(object)values[0] % (long)(object)values[1]);
                        case '^':
                            return (T)(object)(long)System.Math.Pow((long)(object)values[0], (long)(object)values[1]);
                    }
                }
            }
            return default(T);
        }

        private static bool TryParse<T>(string expression, out T result)
        {
            expression = expression.Replace(',', '.');

            bool success = false;
            result = default(T);
            if (typeof(T) == typeof(float))
            {
                float temp = 0.0f;
                success = float.TryParse(expression, NumberStyles.Float, CultureInfo.InvariantCulture.NumberFormat, out temp);
                result = (T)(object)temp;
            }
            else if (typeof(T) == typeof(int))
            {
                int temp = 0;
                success = int.TryParse(expression, NumberStyles.Integer, CultureInfo.InvariantCulture.NumberFormat, out temp);
                result = (T)(object)temp;
            }
            else if (typeof(T) == typeof(double))
            {
                double temp = 0;
                success = double.TryParse(expression, NumberStyles.Float, CultureInfo.InvariantCulture.NumberFormat, out temp);
                result = (T)(object)temp;
            }
            else if (typeof(T) == typeof(long))
            {
                long temp = 0;
                success = long.TryParse(expression, NumberStyles.Integer, CultureInfo.InvariantCulture.NumberFormat, out temp);
                result = (T)(object)temp;
            }
            return success;
        }
    }
}
