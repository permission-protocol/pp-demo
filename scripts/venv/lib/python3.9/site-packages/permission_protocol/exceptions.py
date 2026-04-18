class PermissionProtocolError(Exception):
    """Base SDK exception."""


class PermissionDenied(PermissionProtocolError):
    """Raised when a request is denied or expires."""


class PermissionTimeout(PermissionProtocolError):
    """Raised when waiting for approval times out."""


class AuthenticationError(PermissionProtocolError):
    """Raised when API authentication fails."""


class APIError(PermissionProtocolError):
    """Raised for non-authentication API failures."""
