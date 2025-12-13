# Domain Modeling in Python

Python-specific patterns for type-driven development.

## Pydantic Models (Recommended)

Pydantic provides runtime validation with type hints:

```python
from pydantic import BaseModel, Field, EmailStr, field_validator
from typing import Annotated

class UserId(BaseModel):
    value: Annotated[str, Field(min_length=1, max_length=36)]

    def __str__(self) -> str:
        return self.value

class Email(BaseModel):
    value: EmailStr

class Money(BaseModel):
    cents: Annotated[int, Field(ge=0)]

    @classmethod
    def from_dollars(cls, dollars: float) -> "Money":
        return cls(cents=int(dollars * 100))

    def to_dollars(self) -> float:
        return self.cents / 100

    def __add__(self, other: "Money") -> "Money":
        return Money(cents=self.cents + other.cents)
```

### Pydantic V2 Features

```python
from pydantic import BaseModel, ConfigDict, field_validator

class Order(BaseModel):
    model_config = ConfigDict(frozen=True)  # Immutable

    id: OrderId
    items: list[Item]
    status: OrderStatus

    @field_validator('items')
    @classmethod
    def items_not_empty(cls, v: list[Item]) -> list[Item]:
        if not v:
            raise ValueError('Order must have at least one item')
        return v
```

## dataclasses with Validation

For simpler cases without Pydantic:

```python
from dataclasses import dataclass
from typing import ClassVar
import re

@dataclass(frozen=True)
class Email:
    value: str
    _pattern: ClassVar[re.Pattern] = re.compile(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    )

    def __post_init__(self):
        if not self._pattern.match(self.value):
            raise ValueError(f"Invalid email: {self.value}")

@dataclass(frozen=True)
class PositiveInt:
    value: int

    def __post_init__(self):
        if self.value <= 0:
            raise ValueError(f"Must be positive: {self.value}")
```

## NewType for Simple Aliases

When you just need type distinction (no runtime validation):

```python
from typing import NewType

UserId = NewType('UserId', str)
OrderId = NewType('OrderId', str)
Money = NewType('Money', int)  # Cents

def get_user(user_id: UserId) -> User:
    ...

# Type checker warns, but runtime allows it
get_user(OrderId("order-123"))  # mypy error, but runs
```

**Note**: NewType is compile-time only. For runtime safety, use Pydantic or dataclass.

## Enums for Sum Types

```python
from enum import Enum, auto
from typing import Union
from dataclasses import dataclass

class OrderStatusType(Enum):
    PENDING = auto()
    CONFIRMED = auto()
    SHIPPED = auto()
    DELIVERED = auto()
    CANCELLED = auto()

# With data using dataclasses
@dataclass(frozen=True)
class Pending:
    pass

@dataclass(frozen=True)
class Confirmed:
    confirmed_at: datetime

@dataclass(frozen=True)
class Shipped:
    shipped_at: datetime
    tracking: str

@dataclass(frozen=True)
class Delivered:
    delivered_at: datetime

@dataclass(frozen=True)
class Cancelled:
    reason: str

OrderStatus = Union[Pending, Confirmed, Shipped, Delivered, Cancelled]

# Pattern matching (Python 3.10+)
def handle_order(status: OrderStatus) -> str:
    match status:
        case Pending():
            return "Waiting..."
        case Confirmed(confirmed_at=t):
            return f"Confirmed at {t}"
        case Shipped(tracking=t):
            return f"Track: {t}"
        case Delivered():
            return "Done!"
        case Cancelled(reason=r):
            return f"Cancelled: {r}"
```

## Pydantic Discriminated Unions

```python
from pydantic import BaseModel
from typing import Literal, Union

class CreditCard(BaseModel):
    type: Literal['credit_card'] = 'credit_card'
    number: str
    expiry: str
    cvv: str

class BankTransfer(BaseModel):
    type: Literal['bank_transfer'] = 'bank_transfer'
    iban: str
    bic: str

class PayPal(BaseModel):
    type: Literal['paypal'] = 'paypal'
    email: EmailStr

PaymentMethod = Union[CreditCard, BankTransfer, PayPal]

class Payment(BaseModel):
    amount: Money
    method: PaymentMethod
```

## Result Type

```python
from dataclasses import dataclass
from typing import Generic, TypeVar, Union

T = TypeVar('T')
E = TypeVar('E')

@dataclass(frozen=True)
class Ok(Generic[T]):
    value: T

@dataclass(frozen=True)
class Err(Generic[E]):
    error: E

Result = Union[Ok[T], Err[E]]

def divide(a: float, b: float) -> Result[float, str]:
    if b == 0:
        return Err("division by zero")
    return Ok(a / b)

# Usage
result = divide(10, 2)
match result:
    case Ok(value):
        print(f"Result: {value}")
    case Err(error):
        print(f"Error: {error}")
```

Or use the `result` library:
```bash
pip install result
```

## Non-Empty Collections

```python
from typing import Generic, TypeVar, Sequence
from pydantic import BaseModel, field_validator

T = TypeVar('T')

class NonEmptyList(BaseModel, Generic[T]):
    items: list[T]

    @field_validator('items')
    @classmethod
    def must_not_be_empty(cls, v: list[T]) -> list[T]:
        if not v:
            raise ValueError('List cannot be empty')
        return v

    def first(self) -> T:
        return self.items[0]  # Always safe

    def __len__(self) -> int:
        return len(self.items)

    def __iter__(self):
        return iter(self.items)
```

## Recommended Libraries

| Library | Purpose |
|---------|---------|
| `pydantic` | Data validation and settings |
| `result` | Result type for error handling |
| `returns` | Functional programming utilities |
| `attrs` | Alternative to dataclasses |
| `beartype` | Runtime type checking |
