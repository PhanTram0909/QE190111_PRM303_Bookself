import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/books_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class BookDetailScreen extends StatefulWidget {
  final Book initialBook;

  const BookDetailScreen({super.key, required this.initialBook});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _book;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _errorMessage;

  // Controllers for edit mode
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _ratingController;
  late TextEditingController _notesController;
  String? _selectedGenre;
  String? _selectedStatus;
  late bool _editFavorite;

  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _book = widget.initialBook;
    _initControllers();
  }

  void _initControllers() {
    _titleController = TextEditingController(text: _book.title);
    _authorController = TextEditingController(text: _book.author);
    _ratingController = TextEditingController(
      text: _book.rating != null ? _book.rating.toString() : '',
    );
    _notesController = TextEditingController(text: _book.notes);
    _selectedGenre = _book.genre;
    _selectedStatus = _book.status;
    _editFavorite = _book.favorite;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _ratingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _enterEditMode() {
    setState(() {
      _isEditing = true;
      _errorMessage = null;
      _autovalidateMode = AutovalidateMode.disabled;
      _initControllers();
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _errorMessage = null;
      _initControllers();
    });
  }

  Future<void> _saveEdit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    final ratingParsed = _ratingController.text.trim().isNotEmpty
        ? int.tryParse(_ratingController.text.trim())
        : null;

    try {
      await booksProvider.updateBook(
        oldBook: _book,
        newTitle: _titleController.text.trim(),
        newAuthor: _authorController.text.trim(),
        newGenre: _selectedGenre!,
        newStatus: _selectedStatus!,
        newRating: ratingParsed,
        clearRating: _ratingController.text.trim().isEmpty,
        newNotes: _notesController.text.trim(),
        newFavorite: _editFavorite,
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _isEditing = false;
        _book = _book.copyWith(
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          genre: _selectedGenre,
          status: _selectedStatus,
          rating: ratingParsed,
          clearRating: _ratingController.text.trim().isEmpty,
          notes: _notesController.text.trim(),
          favorite: _editFavorite,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    try {
      await booksProvider.toggleFavorite(_book);
      if (!mounted) return;
      setState(() {
        _book = _book.copyWith(favorite: !_book.favorite);
        _editFavorite = _book.favorite;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorite: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${_book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isDeleting = true;
      });

      final booksProvider = Provider.of<BooksProvider>(context, listen: false);
      try {
        await booksProvider.deleteBook(_book.id);
        if (!mounted) return;
        Navigator.of(context).pop(); // Return to List screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${_book.title}"'),
            backgroundColor: Colors.grey.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete book: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the book is being deleted, show a loader
    if (_isDeleting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Book' : _book.title),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: Icon(
                _book.favorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: _book.favorite ? Colors.amber : null,
              ),
              tooltip: _book.favorite ? 'Unfavorite' : 'Favorite',
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: _enterEditMode,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete',
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _isEditing ? _buildEditForm() : _buildViewMode(),
        ),
      ),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Author Header Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _book.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _book.favorite ? Icons.star_rounded : Icons.star_border_rounded,
                      color: _book.favorite ? Colors.amber.shade700 : Colors.grey.shade400,
                      size: 32,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'by ${_book.author}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Info Cards / Details
        _buildDetailItem(
          icon: Icons.category_outlined,
          label: 'Genre',
          value: _book.genre,
        ),
        const Divider(height: 28),

        _buildDetailItem(
          icon: Icons.bookmark_outline_rounded,
          label: 'Status',
          value: _book.status,
        ),
        const Divider(height: 28),

        _buildDetailItem(
          icon: Icons.star_outline_rounded,
          label: 'Rating',
          value: _book.rating != null ? '${_book.rating} / 5' : 'Not rated',
        ),
        const Divider(height: 28),

        _buildDetailItem(
          icon: Icons.notes_rounded,
          label: 'Notes',
          value: _book.notes.isNotEmpty ? _book.notes : '(None)',
        ),
        const SizedBox(height: 36),

        // Bottom Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Book', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _enterEditMode,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Delete Book', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _confirmDelete,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.blue.shade700),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          AppTextField(
            controller: _titleController,
            label: 'Title',
            hint: 'Enter book title',
            validator: AppValidators.validateTitle,
          ),
          const SizedBox(height: 16),

          // Author
          AppTextField(
            controller: _authorController,
            label: 'Author',
            hint: 'Enter author name',
            validator: AppValidators.validateAuthor,
          ),
          const SizedBox(height: 16),

          // Genre dropdown
          const Text(
            'Genre',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedGenre,
            autovalidateMode: _autovalidateMode,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: AppConstants.genreDropdownHint,
                child: Text(AppConstants.genreDropdownHint),
              ),
              ...AppConstants.genres.map((g) => DropdownMenuItem(
                    value: g,
                    child: Text(g),
                  )),
            ],
            validator: AppValidators.validateGenre,
            onChanged: (val) {
              setState(() {
                _selectedGenre = val;
              });
            },
          ),
          const SizedBox(height: 16),

          // Status dropdown
          const Text(
            'Status',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            autovalidateMode: _autovalidateMode,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: AppConstants.statusDropdownHint,
                child: Text(AppConstants.statusDropdownHint),
              ),
              ...AppConstants.statuses.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  )),
            ],
            validator: AppValidators.validateStatus,
            onChanged: (val) {
              setState(() {
                _selectedStatus = val;
              });
            },
          ),
          const SizedBox(height: 16),

          // Rating
          AppTextField(
            controller: _ratingController,
            label: 'Rating (optional, 0-5)',
            hint: '0 to 5',
            keyboardType: TextInputType.number,
            validator: AppValidators.validateRating,
          ),
          const SizedBox(height: 16),

          // Notes
          AppTextField(
            controller: _notesController,
            label: 'Notes (optional, max 300 characters)',
            hint: 'Personal notes or summary...',
            maxLines: 3,
            validator: AppValidators.validateNotes,
          ),
          const SizedBox(height: 16),

          // Favorite toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Favorite', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Mark this book as one of your favorites'),
            value: _editFavorite,
            onChanged: (val) {
              setState(() {
                _editFavorite = val;
              });
            },
          ),
          const SizedBox(height: 20),

          // Error message below form if any
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Save and Cancel buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Save',
                  onPressed: _saveEdit,
                  isLoading: _isSaving,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AppButton(
                  text: 'Cancel',
                  type: AppButtonType.outlined,
                  onPressed: _isSaving ? null : _cancelEdit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
