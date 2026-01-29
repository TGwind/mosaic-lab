---
title: TypeScript 入门到精通：2024完整指南
date: 2026-01-26
tags:
  - TypeScript
  - JavaScript
  - 前端开发
  - 教程
categories:
  - 技术
cover: https://images.unsplash.com/photo-1516116216624-53e697fedbea?w=800&h=400&fit=crop
description: 最全面的 TypeScript 中文教程，从基础语法到高级类型，涵盖实际项目中的最佳实践，助你成为 TypeScript 高手。
keywords: TypeScript教程, TypeScript入门, TS类型, 泛型, 类型体操, 前端开发, JavaScript
---

## 为什么学习 TypeScript？

TypeScript 已经成为现代前端开发的标配。据 2023 年 State of JS 调查，超过 80% 的开发者正在使用或计划使用 TypeScript。

<!-- more -->

### TypeScript 的优势

1. **类型安全**：在编译时发现错误
2. **更好的 IDE 支持**：智能提示、自动补全
3. **代码可维护性**：类型即文档
4. **大型项目必备**：团队协作更顺畅

## 基础类型

### 原始类型

```typescript
// 字符串
let name: string = 'BitMosaic';

// 数字
let age: number = 25;

// 布尔值
let isActive: boolean = true;

// null 和 undefined
let empty: null = null;
let notDefined: undefined = undefined;

// Symbol
let sym: symbol = Symbol('key');

// BigInt
let bigNum: bigint = 100n;
```

### 数组

```typescript
// 两种写法
let numbers: number[] = [1, 2, 3];
let strings: Array<string> = ['a', 'b', 'c'];

// 只读数组
let readonlyArr: readonly number[] = [1, 2, 3];
```

### 元组

```typescript
// 固定长度和类型的数组
let tuple: [string, number] = ['hello', 42];

// 可选元素
let optionalTuple: [string, number?] = ['hello'];

// 剩余元素
let restTuple: [string, ...number[]] = ['hello', 1, 2, 3];
```

### 对象类型

```typescript
// 接口定义对象结构
interface User {
  id: number;
  name: string;
  email?: string; // 可选属性
  readonly createdAt: Date; // 只读属性
}

const user: User = {
  id: 1,
  name: 'Over',
  createdAt: new Date(),
};
```

## 函数类型

### 函数声明

```typescript
// 参数和返回值类型
function add(a: number, b: number): number {
  return a + b;
}

// 箭头函数
const multiply = (a: number, b: number): number => a * b;

// 可选参数
function greet(name: string, greeting?: string): string {
  return `${greeting || 'Hello'}, ${name}!`;
}

// 默认参数
function greet2(name: string, greeting: string = 'Hello'): string {
  return `${greeting}, ${name}!`;
}

// 剩余参数
function sum(...numbers: number[]): number {
  return numbers.reduce((a, b) => a + b, 0);
}
```

### 函数重载

```typescript
function process(x: string): string;
function process(x: number): number;
function process(x: string | number): string | number {
  if (typeof x === 'string') {
    return x.toUpperCase();
  }
  return x * 2;
}
```

## 联合类型与交叉类型

### 联合类型

```typescript
// 可以是多种类型之一
type StringOrNumber = string | number;

function printId(id: StringOrNumber) {
  if (typeof id === 'string') {
    console.log(id.toUpperCase());
  } else {
    console.log(id);
  }
}
```

### 交叉类型

```typescript
// 组合多个类型
interface Name {
  name: string;
}

interface Age {
  age: number;
}

type Person = Name & Age;

const person: Person = {
  name: 'Over',
  age: 25,
};
```

## 泛型

泛型是 TypeScript 最强大的特性之一。

### 泛型函数

```typescript
// T 是类型参数
function identity<T>(arg: T): T {
  return arg;
}

// 使用
const str = identity<string>('hello');
const num = identity(42); // 类型推断
```

### 泛型接口

```typescript
interface Response<T> {
  code: number;
  message: string;
  data: T;
}

interface User {
  id: number;
  name: string;
}

const userResponse: Response<User> = {
  code: 200,
  message: 'success',
  data: { id: 1, name: 'Over' },
};
```

### 泛型约束

```typescript
// 约束 T 必须有 length 属性
interface Lengthwise {
  length: number;
}

function logLength<T extends Lengthwise>(arg: T): T {
  console.log(arg.length);
  return arg;
}

logLength('hello'); // OK
logLength([1, 2, 3]); // OK
logLength(123); // Error: number 没有 length 属性
```

### 常用泛型工具类型

```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

// Partial - 所有属性变为可选
type PartialUser = Partial<User>;

// Required - 所有属性变为必需
type RequiredUser = Required<PartialUser>;

// Pick - 选取部分属性
type UserBasic = Pick<User, 'id' | 'name'>;

// Omit - 排除部分属性
type UserWithoutEmail = Omit<User, 'email'>;

// Record - 创建对象类型
type UserMap = Record<string, User>;

// Readonly - 所有属性变为只读
type ReadonlyUser = Readonly<User>;
```

## 类型守卫

```typescript
// typeof 守卫
function padLeft(value: string, padding: string | number) {
  if (typeof padding === 'number') {
    return ' '.repeat(padding) + value;
  }
  return padding + value;
}

// in 守卫
interface Bird {
  fly(): void;
}

interface Fish {
  swim(): void;
}

function move(animal: Bird | Fish) {
  if ('fly' in animal) {
    animal.fly();
  } else {
    animal.swim();
  }
}

// 自定义类型守卫
function isFish(animal: Bird | Fish): animal is Fish {
  return (animal as Fish).swim !== undefined;
}
```

## 高级类型

### 条件类型

```typescript
type IsString<T> = T extends string ? true : false;

type A = IsString<string>; // true
type B = IsString<number>; // false

// 实际应用：提取数组元素类型
type ElementType<T> = T extends (infer E)[] ? E : T;

type C = ElementType<string[]>; // string
type D = ElementType<number>; // number
```

### 映射类型

```typescript
// 将所有属性变为可选
type MyPartial<T> = {
  [P in keyof T]?: T[P];
};

// 将所有属性变为只读
type MyReadonly<T> = {
  readonly [P in keyof T]: T[P];
};

// 添加前缀
type Getters<T> = {
  [P in keyof T as `get${Capitalize<string & P>}`]: () => T[P];
};

interface Person {
  name: string;
  age: number;
}

type PersonGetters = Getters<Person>;
// { getName: () => string; getAge: () => number; }
```

### 模板字面量类型

```typescript
type EventName = 'click' | 'focus' | 'blur';
type EventHandler = `on${Capitalize<EventName>}`;
// 'onClick' | 'onFocus' | 'onBlur'

type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type ApiEndpoint = `/api/${string}`;
type FullEndpoint = `${HttpMethod} ${ApiEndpoint}`;
```

## 实战技巧

### 1. 严格模式配置

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true
  }
}
```

### 2. 类型断言

```typescript
// as 语法（推荐）
const input = document.getElementById('input') as HTMLInputElement;

// 非空断言
function process(value: string | null) {
  // 确定 value 不为 null 时使用
  console.log(value!.toUpperCase());
}
```

### 3. 声明文件

```typescript
// types/custom.d.ts
declare module '*.svg' {
  const content: string;
  export default content;
}

declare global {
  interface Window {
    myCustomProperty: string;
  }
}
```

### 4. 类型与接口的选择

```typescript
// 接口 - 用于定义对象结构，支持声明合并
interface User {
  name: string;
}
interface User {
  age: number;
}
// User 现在有 name 和 age

// 类型别名 - 用于复杂类型，如联合类型、交叉类型
type Status = 'pending' | 'success' | 'error';
type Callback = (data: string) => void;
```

## 常见错误与解决方案

### 错误1：类型"X"不能赋值给类型"Y"

```typescript
// 问题
const user: { name: string } = { name: 'Over', age: 25 }; // Error

// 解决：扩展类型或使用类型断言
interface User {
  name: string;
  age?: number;
}
const user: User = { name: 'Over', age: 25 };
```

### 错误2：对象可能为 "undefined"

```typescript
// 问题
function getLength(arr?: string[]) {
  return arr.length; // Error
}

// 解决：可选链或类型守卫
function getLength(arr?: string[]) {
  return arr?.length ?? 0;
}
```

## 推荐学习资源

1. [TypeScript 官方文档](https://www.typescriptlang.org/docs/)
2. [TypeScript Deep Dive](https://basarat.gitbook.io/typescript/)
3. [Type Challenges](https://github.com/type-challenges/type-challenges)

## 总结

TypeScript 是提升代码质量和开发效率的利器：

- 从基础类型开始，逐步掌握
- 善用泛型，提高代码复用性
- 理解类型推断，减少冗余类型注解
- 实践类型体操，提升类型编程能力

持续练习，你会发现 TypeScript 让开发变得更加愉快！

---

有问题欢迎评论区讨论！
