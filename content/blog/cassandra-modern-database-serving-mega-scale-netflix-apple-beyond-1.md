---
title: "Cassandra: The Modern Database Serving Mega-Scale at Netflix, Apple, and Beyond (1)"
date: 2025-12-30T10:00:00+11:00
draft: false
tags: ["cassandra", "database", "nosql", "distributed-systems", "architecture"]
description: "Deep dive into Apache Cassandra's architecture, exploring how it organizes data using rings, tokens, and partition keys to achieve massive scale"
---

# Cassandra: The Modern Database Serving Mega-Scale at Netflix, Apple, and Beyond (1)

## Introduction
ကျွန်တော် DynamoDB နဲ့ အလုပ်လုပ်ခဲ့တဲ့ အတွေ့အကြုံ၊ Kubernetes ပေါ်မှာ in-house Cassandra clusters တွေ host ခဲ့တဲ့ အတွေ့အကြုံတွေအပေါ် အခြေခံပြီး modern NoSQL databases တွေအကြောင်း deep dive ဆင်းကြည့်ကြတာပေါ့။ Cassandra က ပြောစရာ concept တွေ တော်တော်များလို့ ဒါကို ပထမဆုံး series အနေနဲ့ စလိုက်ပါတယ်။

## What is Cassandra?
**Apache Cassandra** ဆိုတာ open-source, distributed NoSQL database တစ်ခုပါ။ သူက high write throughput ရဖို့၊ massive scale လုပ်နိုင်ဖို့နဲ့ continuous availability အတွက် built ဖြစ်ပြီးသားပါ။ Cassandra က data တွေကို tables, rows, နဲ့ columns တွေနဲ့ သိမ်းဆည်းပါတယ်။

Traditional databases တွေနဲ့မတူတာက Cassandra က **peer-to-peer architecture** ကို သုံးထားပြီး **tunable consistency** ပေးထားပါတယ်။ ဆိုလိုတာက developer က ကိုယ့် system ရဲ့ data accuracy နဲ့ speed ကြားမှာ trade-off ကို စိတ်ကြိုက် balance လုပ်လို့ရတယ်။ AWS DynamoDB ကို သုံးဖူးရင်တော့ core principles တွေက တော်တော်လေး ဆင်တာကို တွေ့ရမှာပါ။

---

## How is it different from a traditional RDBMS?

MySQL ဒါမှမဟုတ် PostgreSQL လိုမျိုး traditional RDBMS တွေမှာ ပုံမှန်အားဖြင့် queries တွေအကုန်လုံးကို handle လုပ်တဲ့ primary instance တစ်ခုပဲ ရှိတတ်ပါတယ် (RDBMS တွေမှာ advanced features တွေ အများကြီးရှိပေမဲ့ ဒါကို နောက်မှ ဆွေးနွေးပါမယ်)။ Cassandra ကတော့ design စွဲကတည်းက queries တွေကို handle လုပ်ဖို့ node (instance) တစ်ခုထက်မက သုံးဖို့ ရည်ရွယ်ထားတာပါ။ Features တွေ ဒါမှမဟုတ် architecture အရ ကွာခြားချက်တွေ အများကြီးရှိပေမဲ့ ဒီအခြေခံကနေပဲ စကြည့်ရအောင်။

* **RDBMS:** Single node ကနေ စတင်ပြီး Vertical Scaling ကို အားကိုးပါတယ်။
* **Cassandra:** Distributed multiple nodes ကနေ စတင်ပြီး Horizontal Scaling ကို အားကိုးပါတယ်။

### Cassandra's Core Idea: Continuous Availability

စဥ်းစားကြည့်ပါ - သင့် RDBMS database က machine (computer) တစ်ခုပေါ်မှာ run နေပြီး application က အဲဒီ machine ကို အားကိုးနေတယ်ဆိုပါစို့။ တကယ်လို့ အဲဒီ machine က အကြောင်းတစ်ခုခုကြောင့် down သွားရင် application က unavailable ဖြစ်သွားပါလိမ့်မယ်။ Backup မရှိရင် data တွေ ပျောက်နိုင်ပါတယ်။ Backup ရှိတယ်တောင် restore လုပ်ဖို့ အချိန်ယူရပြီး downtime ရှည်သွားမှာပါ။

ဒါပေမဲ့ database က multiple nodes (computers) တွေပေါ်မှာ run နေရင်ရော? Node တစ်ခု down သွားတယ်တောင် database က available ဖြစ်နေဦးမှာပါ။ ဒါကြောင့် Cassandra က **continuous availability** ကို guarantee လုပ်နိုင်တာပါ။

### Cassandra's Core Idea: True Horizontal Scalability

သင့် application မှာ Facebook, Netflix လို customers အများကြီးရှိတယ်ဆိုပါစို့။ Machine တစ်ခုတည်းပေါ်က database က scale လုပ်လို့ မရတော့ပါဘူး။ Vertically scale up လုပ်လို့ရပါတယ် (bigger machine - more CPUs, Memory စတာတွေ သုံးတာ) ဒါပေမဲ့ တစ်နေ့တော့ limit ကို ထိသွားမှာပါ။ Applications တွေအတွက် horizontal scaling (adding more nodes/machines) က အမြဲတမ်း ပိုကောင်းပါတယ်။ Databases တွေအတွက်လည်း အတူတူပါပဲ (database က application တစ်ခုပါပဲ)။ ဒါကြောင့် Cassandra က အမှန်တကယ် scalable ဖြစ်တာပါ။

ဒါပေမဲ့ multiple nodes ရှိလို့နဲ့ အလိုအလျောက် scale လုပ်မှာ မဟုတ်ပါဘူး။ Cassandra က scalability ရအောင် tricks အများကြီး သုံးထားပါတယ်။

### Scalability: Peer-to-Peer vs. Master-Slave
Database အများစု (MongoDB, MySQL, Postgres) က **Master-Slave (Primary-Replica)** architecture ကို သုံးပါတယ်။ Writes တွေက Primary ဆီပဲသွားတဲ့အတွက် write-heavy apps တွေမှာ Primary node က bottleneck ဖြစ်လာပါတယ်။ Read-heavy applications တွေအတွက်တော့ ဒီ architecture က အလုပ်ဖြစ်ပါတယ်။ ဒါပေမဲ့ write-heavy workloads တွေအတွက်တော့ တစ်နေ့တော့ Primary က scale လုပ်လို့ မရတော့ပါဘူး။

Cassandra ရဲ့ **Peer-to-Peer** architecture မှာတော့ node တိုင်းက read ရော write requests တွေကိုပါ လက်ခံနိုင်ပါတယ်။ ဒါကြောင့် write scalability ကို အမှန်တကယ် ရရှိနိုင်တာပါ။

**ဒါပေမဲ့ peer-to-peer architecture က အလွယ်တကူ implement လုပ်လို့ရတာ မဟုတ်ပါဘူး။** Write query က node အားလုံးဆီ သွားရင် scalable မဖြစ်တော့ပါဘူး။ Random nodes တွေမှာ write လုပ်လို့လည်း မရပါဘူး - ဘာကြောင့်လဲဆိုတော့ နောက်မှ ဘယ်မှာ read လုပ်ရမလဲဆိုတာ မသိတော့လို့ပါ။

**ဒါကြောင့် အဓိက မေးခွန်းက:** ဘယ် node က ဘယ် data ကို သိမ်းမလဲဆိုတာ ဘယ်လို ဆုံးဖြတ်မလဲ? Cassandra က ဒါကို ဘယ်လို design လုပ်ထားလဲ?

{{< mermaid >}}
graph TB
    subgraph "Master-Slave Architecture"
        Client1[Client] -->|All Writes| Master[Master Node]
        Master -->|Replication| Slave1[Replica 1]
        Master -->|Replication| Slave2[Replica 2]
        Client1 -->|Reads| Slave1
        Client1 -->|Reads| Slave2
        style Master fill:#ff6b6b
    end
    
    subgraph "Cassandra Peer-to-Peer"
        Client2[Client] -->|Read/Write| NodeA[Node A]
        Client2 -->|Read/Write| NodeB[Node B]
        Client2 -->|Read/Write| NodeC[Node C]
        NodeA <-->|Equal Peers| NodeB
        NodeB <-->|Equal Peers| NodeC
        NodeC <-->|Equal Peers| NodeA
        style NodeA fill:#51cf66
        style NodeB fill:#51cf66
        style NodeC fill:#51cf66
    end
{{< /mermaid >}}

---

## How Cassandra Store Data

Cassandra မှာ Data တွေကို Node တွေပေါ်မှာ စနစ်တကျ ခွဲဝေသိမ်းဆည်းဖို့ **Consistent Hashing** ဆိုတဲ့ Concept ကို အသုံးပြုပြီး အဓိက အစိတ်အပိုင်း (၃) ခုနဲ့ အလုပ်လုပ်ပါတယ်။ ဒါတွေက Cassandra ရဲ့ distributed architecture ရဲ့ အခြေခံ building blocks တွေပါ။

{{< mermaid >}}
graph LR
    subgraph "Data Organization Components"
        A[Partition Key] -->|Hash Function| B[Token]
        B -->|Lookup| C[Token Range]
        C -->|Maps to| D[Node]
        D -->|Stores| E[Actual Data]
    end
    
    style A fill:#4dabf7
    style B fill:#ffd43b
    style C fill:#ff8787
    style D fill:#51cf66
    style E fill:#845ef7
{{< /mermaid >}}

## 1. Nodes (The Physical Layer)
- Data တွေကို အမှန်တကယ် Store လုပ်မယ့် Physical Server (သို့မဟုတ်) Virtual Machine တွေကို ခေါ်တာပါ။
- ဥပမာ - EC2 instances တစ်ခု ဒါမှမဟုတ် computers အစုတစ်ခု ဖြစ်နိုင်ပါတယ်။

## 2. The Ring (The Logical Layer)
- Cassandra Cluster ထဲမှာရှိတဲ့ Node အားလုံးကို စက်ဝိုင်းပုံစံ တန်းစီထားတယ်လို့ စိတ်ကူးကြည့်ပါ။ ဒါက math concept တစ်ခု ပါ။
- ဒီ **Ring Architecture** ကြောင့် Data တွေကို ဘယ် Node မှာမဆို အလွယ်တကူ ရှာဖွေနိုင်ပြီး Cluster ကို **Scale out** လုပ်ရတာ လွယ်ကူစေပါတယ်။
- Ring က circular ဖြစ်တဲ့အတွက် အစနဲ့ အဆုံး မရှိပါဘူး - wraps around လုပ်ပါတယ်။

## 3. Tokens & Ranges (The Distribution Logic)
- Data တစ်ခု (Row) ဝင်လာရင် Cassandra က **Partition Key** ကိုယူပြီး **Hash function (Murmur3 Algorithm)** နဲ့ တွက်ချက်လိုက်ပါတယ်။ ထွက်လာတဲ့ Hash value ကို **Token** လို့ ခေါ်ပါတယ်။
- **Token Range:** Ring တစ်ခုလုံးကို အပိုင်းအခြား (Ranges) တွေ ခွဲထားပါတယ်။ Token တွေက ownership boundaries တွေကို သတ်မှတ်ပေးပါတယ်။
- **Ownership:** Node တစ်ခုချင်းစီက သတ်မှတ်ထားတဲ့ **Token Range** တစ်ခုကို တာဝန်ယူရပါတယ်။
   - **Clockwise Traversal:** Ownership ကို သတ်မှတ်ရာမှာ **လက်ယာရစ် (Clockwise) အတိုင်း** ကြည့်ပါတယ်။ Node တစ်ခုဟာ ရှေ့က node ရဲ့ token နောက်ပိုင်းကနေ သူ့ရဲ့ ကိုယ်ပိုင် token အထိ range ကို **ပိုင်ဆိုင်** တာ ဖြစ်ပါတယ်။

### Logical Example (Token Ranges & Ownership)
နားလည်ရလွယ်အောင် Ring တစ်ခုလုံးမှာ **Token အကွာအဝေး 0 to 100** ရှိတယ်လို့ ယူဆကြည့်ရအောင်။ ဒါက simplified example ပါ။ 

**Ring:** 0 → 25 → 50 → 75 → 100 (wraps around back to 0)

**Tokens (one per node):**
- Node A → 25
- Node B → 50
- Node C → 75
- Node D → 100

| Node   | Assigned Token | Responsible Range (Ownership)          |
|--------|----------------|---------------------------------------|
| Node A | 25             | (100 to 25] - ၁၀၀ ထက်ကျော်ရင် (သို့) ၀ ကနေ ၂၅ အထိ |
| Node B | 50             | (25 to 50] - ၂၅ ထက်ကြီးပြီး ၅၀ အထိ  |
| Node C | 75             | (50 to 75] - ၅၀ ထက်ကြီးပြီး ၇၅ အထိ  |
| Node D | 100            | (75 to 100] - ၇၅ ထက်ကြီးပြီး ၁၀၀ အထိ |


{{< cassandra-ring >}}

### Virtual Nodes (VNodes) - Optional Concept
**VNodes** ဆိုတာ Cassandra ရဲ့ နောက်ထပ် concept တစ်ခုပါ။ Node တစ်ခုနဲ့ token တစ်ခု 1:1 map လုပ်မယ့်အစား node တစ်ခုချင်းစီက small token ranges အများကြီးကို own လုပ်ပါတယ်။ အခုက simplicity အတွက် ဒီ concept ကို ခဏချန်ထားလိုက်ပါမယ် - cognitive load လျှော့ဖို့ပါ။ Advanced topics တွေမှာ ပြန်ရှင်းပြပါမယ်။

---

## The Secret Sauce: The Partition Key

အခု ကျွန်တော်တို့ သိလာပြီ - ဘယ် physical nodes တွေက ဘယ် token ranges တွေကို own လုပ်တယ်ဆိုတာ။ ဒါပေမဲ့ Cassandra က ဒါတွေကို ဘယ်လို အသုံးချလဲဆိုတာ မသိသေးပါဘူး။

Ring ထဲမှာ data ကို ရှာဖို့ Cassandra က သီးသန့် table schema သုံးပါတယ်။ Cassandra table မှာ အဓိက component နှစ်ခု ရှိရမယ်: **partition key** နး့ **clustering (sort) key**။ ဒီ keys နှစ်ခု ပေါင်းလို့ table အတွက် primary key ဖြစ်သွားပါတယ်။ Partition key မှာရော clustering key မှာရော columns အများကြီး ပါလို့ရပါတယ်။

Primary key မှာ အဓိက အစိတ်အပိုင်း နှစ်ခု ပါဝင်ပါတယ်:

* **Partition Key:** ဘယ် node မှာ data သွားသိမ်းမလဲဆိုတာ ဆုံးဖြတ်ပေးပါတယ်။
* **Clustering Key:** အဲဒီ node ထဲမှာ data တွေကို ဘယ်လို sort လုပ်မလဲဆိုတာ ဆုံးဖြတ်ပါတယ်။

{{< mermaid >}}
graph TD
    subgraph "Primary Key Structure"
        PK[PRIMARY KEY] --> Parts["((partition_key), clustering_key)"]
        Parts --> PartKey[Partition Key]
        Parts --> ClustKey[Clustering Key]
        
        PartKey --> Purpose1["Determines which<br/>node stores data"]
        ClustKey --> Purpose2["Determines sort order<br/>within partition"]
    end
    
    style PK fill:#845ef7
    style PartKey fill:#ff6b6b
    style ClustKey fill:#51cf66
{{< /mermaid >}}

### Example Schema
```sql
CREATE TABLE orders_by_customer (
    customer_id uuid,      -- Partition key
    order_id uuid,         -- Clustering key
    order_date timestamp,
    total_amount decimal,
    status text,
    PRIMARY KEY ((customer_id), order_id)
);
```

## How Read/Write Requests Work

Cassandra ရဲ့ distributed architecture မှာ read/write requests တွေက ဘယ်လို အလုပ်လုပ်လဲဆိုတာ နားလည်ထားဖို့ အရေးကြီးပါတယ်။

### The Coordinator Node Pattern

Cassandra မှာ **အထူးသဖြင့် စိတ်ဝင်စားစရာကောင်းတဲ့** အချက်က **ဘယ် node မဆို coordinator node အဖြစ် လုပ်ဆောင်နိုင်တယ်** ဆိုတာပါ။ Client က cluster ထဲက node တစ်ခုကို ချိတ်ဆက်လိုက်တဲ့ အခါ အဲဒီ node က **coordinator** အဖြစ် တာဝန်ယူပြီး request ကို လုပ်ဆောင်ပေးပါတယ်။

### Write Request Flow

**Write request** တစ်ခုဝင်လာတဲ့အခါ အဆင့်တိုင်းမှာ ဒီလိုဖြစ်ပါတယ်:

#### Step 1: Hash Calculation
Application က data သိမ်းဖို့ `customer_id = "user123"` ပါတဲ့ order တစ်ခု insert လုပ်လိုက်တယ်ဆိုပါစို့။

```sql
INSERT INTO orders_by_customer (customer_id, order_id, order_date, total_amount, status)
VALUES ('user123', uuid(), '2025-12-30', 99.99, 'pending');
```

**Coordinator node** (ဥပမာ Node A) က **Partition Key** (`customer_id = "user123"`) ကို hash function (Murmur3) ထဲ ထည့်ပြီး **Token** တစ်ခု ထုတ်ပေးပါတယ်။

* **Hash Result:** Token = `62`

{{< mermaid >}}
sequenceDiagram
    participant App as Application
    participant NodeA as Node A<br/>(Coordinator)
    participant Ring as Token Ring
    participant NodeC as Node C<br/>(Owner)
    
    App->>NodeA: INSERT (customer_id='user123')
    Note over NodeA: Hash('user123')<br/>= Token 62
    NodeA->>Ring: Lookup Token 62
    Ring-->>NodeA: Token 62 → Node C<br/>(Range 50-75)
    NodeA->>NodeC: Forward Write Request
    NodeC->>NodeC: Write to Disk
    NodeC-->>NodeA: Success
    NodeA-->>App: Write Confirmed
    
    Note over NodeC: Data now stored<br/>in Node C
{{< /mermaid >}}

#### Step 2: Token Range Lookup
Coordinator က ring topology ကို ကြည့်ပြီး token `62` ဟာ ဘယ် node ရဲ့ responsible range ထဲမှာ ကျသလဲ စစ်ဆေးပါတယ်။

* Token `62` က range `(50, 75]` ထဲမှာ ကျတဲ့အတွက် **Node C** မှာ သိမ်းရမယ်လို့ သိသွားပါတယ်။

#### Step 3: Data Routing & Storage
Coordinator (Node A) က data ကို **Node C** ဆီ forward လုပ်ပြီး Node C မှာ disk ပေါ် သွားရောက်သိမ်းဆည်းပါတယ်။ Write operation အောင်မြင်သွားတဲ့အခါ coordinator က client ဆီ success response ပြန်ပို့ပေးပါတယ်။


### Read Request Flow

**Read request** လာတဲ့အခါလည်း အလားတူပဲ ဖြစ်ပါတယ်:

#### Step 1: Client Connects to Any Node
Application က `customer_id = "user123"` အတွက် orders တွေ query လုပ်လိုက်တယ်ဆိုပါစို့:

```sql
SELECT * FROM orders_by_customer WHERE customer_id = 'user123';
```

Client က **Node A** ကို ချိတ်ဆက်ထားတယ်ဆိုရင် Node A က **coordinator** အဖြစ် တာဝန်ယူပါတယ်။

{{< mermaid >}}
sequenceDiagram
    participant App as Application
    participant NodeA as Node A<br/>(Coordinator)
    participant Ring as Token Ring
    participant NodeC as Node C<br/>(Data Owner)
    
    App->>NodeA: SELECT (customer_id='user123')
    Note over NodeA: Hash('user123')<br/>= Token 62
    NodeA->>Ring: Lookup Token 62
    Ring-->>NodeA: Token 62 → Node C
    NodeA->>NodeC: Fetch Data Request
    NodeC->>NodeC: Read from Disk
    NodeC-->>NodeA: Return Data
    NodeA-->>App: Query Results
    
    Note over App,NodeC: Any node can be coordinator!
{{< /mermaid >}}

#### Step 2: Hash & Locate Data
Coordinator (Node A) က partition key (`customer_id = "user123"`) ကို hash လုပ်ပြီး token `62` ကို ရပါတယ်။ Ring topology ကို ကြည့်တဲ့အခါ data က **Node C** မှာ ရှိတယ်လို့ သိသွားပါတယ်။

#### Step 3: Fetch & Return
Node A က Node C ဆီ request ပို့ပြီး data ကို fetch လုပ်ပါတယ်။ Node C က data ကို ပြန်ပို့လိုက်တဲ့အခါ Node A က client ဆီ ပြန်ပြီး forward လုပ်ပေးပါတယ်။

### Why This Matters: No Single Point of Failure

ဒီ architecture ရဲ့ အဓိက အားသာချက်က **flexibility** ပါ။ Client က cluster ထဲက ဘယ် node ကိုမဆို ချိတ်ဆက်နိုင်ပြီး node တိုင်းက coordinator အဖြစ် လုပ်ဆောင်နိုင်တဲ့အတွက် **single point of failure** မရှိပါဘူး။ Node တစ်ခု down သွားရင်တောင် client က အခြား node တွေဆီ ချိတ်ဆက်နိုင်ပါတယ်။

{{< mermaid >}}
graph TD
    subgraph "Scenario 1: Node A as Coordinator"
        Client1[Client] -->|Connect| NA1[Node A ✓]
        NA1 -->|Route| NB1[Node B]
        NA1 -->|Route| NC1[Node C]
        style NA1 fill:#51cf66
    end
    
    subgraph "Scenario 2: Node A Down - Use Node B"
        Client2[Client] -.->|X Down| NA2[Node A ✗]
        Client2 -->|Failover| NB2[Node B ✓]
        NB2 -->|Route| NC2[Node C]
        style NA2 fill:#ff6b6b
        style NB2 fill:#51cf66
    end
    
    Note1[No Single Point<br/>of Failure!]
    style Note1 fill:#ffd43b
{{< /mermaid >}}

---

## Summary

**Partition Key** ဆိုတာ Cassandra ရဲ့ write ရော read request တွေအတွက်ပါ အသက်သွေးကြောပဲ ဖြစ်ပါတယ်။ တကယ်လို့ သင်က query မှာ partition key ကို ထည့်မပေးခဲ့ဘူးဆိုရင် Cassandra က data ဘယ်မှာရှိမှန်း မသိတော့ဘဲ node အားလုံးကို လိုက်မွှေရပါလိမ့်မယ်။ ဒါကို **Full Cluster Scan** လို့ ခေါ်ပြီး performance ကို အဆိုးရွားဆုံး ထိခိုက်စေပါတယ်။

**ကျွန်တော်တို့ ယခု သိလာပြီ:**
- Cassandra က data တွေကို multiple nodes တွေပေါ်မှာ ဘယ်လို organize လုပ်လဲ
- Ring topology နဲ့ token ranges တွေက ဘယ်လို အလုပ်လုပ်လဲ
- Partition key က data ရဲ့ location ကို ဘယ်လို determine လုပ်လဲ
- Write နဲ့ read requests တွေက ring မှာ ဘယ်လို route လုပ်လဲ

{{< mermaid >}}
graph LR
    subgraph "With Partition Key ✓"
        Q1[Query with<br/>Partition Key] -->|Hash| T1[Token 62]
        T1 -->|Direct| N1[Node C Only]
        style Q1 fill:#51cf66
        style N1 fill:#51cf66
    end
    
    subgraph "Without Partition Key ✗"
        Q2[Query without<br/>Partition Key] -->|Scan| NA[Node A]
        Q2 -->|Scan| NB[Node B]
        Q2 -->|Scan| NC[Node C]
        Q2 -->|Scan| ND[Node D]
        style Q2 fill:#ff6b6b
        style NA fill:#ff6b6b
        style NB fill:#ff6b6b
        style NC fill:#ff6b6b
        style ND fill:#ff6b6b
    end
{{< /mermaid >}}

---

## Next Topic: Resilience & Consistency

အခု logic အတိုင်းဆိုရင် data က node တစ်ခုတည်းမှာပဲ သွားသိမ်းတာ မဟုတ်လား? အဲဒီ node သာ down သွားရင် ကျွန်တော်တို့ data တွေ ပျောက်ကုန်မှာလား? ကျွန်တော် အစောပိုင်းမှာ Cassandra က highly available ဖြစ်တယ်လို့ ပြောခဲ့တယ်။ ဒါက ဘာကို ဆိုလိုတာလဲ?

ဒီအကြောင်းအရာတွေကိုတော့ နောက်ဆောင်းပါးမှာ **Replication Factor** နဲ့ **Tunable Consistency** အကြောင်းတွေနဲ့အတူ အသေးစိတ် ဆက်လက်ဆွေးနွေးသွားပါမယ်။

