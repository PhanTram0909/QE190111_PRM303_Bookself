import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/books_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';
import 'book_detail_screen.dart';

class BooksListScreen extends StatefulWidget {
  const BooksListScreen({super.key});

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  // Add Book Form Controllers
  final _addFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _ratingController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  String? _selectedGenre;
  String? _selectedStatus;
  AutovalidateMode _addAutovalidateMode = AutovalidateMode.disabled;

  bool _isAdding = false;
  String? _addFormError;
  bool _isAddFormExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<BooksProvider>(context, listen: false)
            .initUser(auth.currentUser!.uid);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _ratingController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearAddForm() {
    _titleController.clear();
    _authorController.clear();
    _ratingController.clear();
    _notesController.clear();
    setState(() {
      _selectedGenre = null;
      _selectedStatus = null;
      _addAutovalidateMode = AutovalidateMode.disabled;
      _addFormError = null;
    });
    _addFormKey.currentState?.reset();
  }

  Future<void> _submitAddBook() async {
    setState(() {
      _addAutovalidateMode = AutovalidateMode.onUserInteraction;
      _addFormError = null;
    });

    if (!_addFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isAdding = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);

    final ratingParsed = _ratingController.text.trim().isNotEmpty
        ? int.tryParse(_ratingController.text.trim())
        : null;

    try {
      await booksProvider.addBook(
        userId: auth.currentUser!.uid,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        genre: _selectedGenre!,
        status: _selectedStatus!,
        rating: ratingParsed,
        notes: _notesController.text.trim(),
        favorite: false,
      );

      if (!mounted) return;

      setState(() {
        _isAdding = false;
      });

      _clearAddForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.bookAddedSuccess),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAdding = false;
        _addFormError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _handleLogout() async {
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Clear provider state / listeners on logout
    booksProvider.clear();
    await authProvider.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final booksProvider = Provider.of<BooksProvider>(context);
    final userEmail = authProvider.currentUser?.email ?? '';

    final filteredBooks = booksProvider.filteredBooks;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (userEmail.isNotEmpty)
              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SECTION A: Add Book Form Card
              _buildAddBookCard(),

              const SizedBox(height: 12),

              // SECTION C: Search & Filter & Summary Section
              _buildFilterAndSummaryCard(booksProvider),

              const SizedBox(height: 12),

              // SECTION B: Book List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Text(
                  'Your Books (${filteredBooks.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),

              // SECTION B: Book List or Empty State
              if (booksProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredBooks.isEmpty)
                const EmptyState(message: AppConstants.noBooksFound)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredBooks.length,
                  itemBuilder: (ctx, index) {
                    final book = filteredBooks[index];
                    return BookCard(
                      book: book,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookDetailScreen(initialBook: book),
                          ),
                        );
                      },
                      onFavoriteToggle: () {
                        booksProvider.toggleFavorite(book);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddBookCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _addFormKey,
          autovalidateMode: _addAutovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isAddFormExpanded = !_isAddFormExpanded;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Add New Book',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Icon(
                      _isAddFormExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
              if (_isAddFormExpanded) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Title
                AppTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Enter book title',
                  validator: AppValidators.validateTitle,
                ),
                const SizedBox(height: 14),

                // Author
                AppTextField(
                  controller: _authorController,
                  label: 'Author',
                  hint: 'Enter author name',
                  validator: AppValidators.validateAuthor,
                ),
                const SizedBox(height: 14),

                // Genre dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Genre',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGenre,
                      autovalidateMode: _addAutovalidateMode,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      hint: const Text(AppConstants.genreDropdownHint),
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
                  ],
                ),
                const SizedBox(height: 14),

                // Status dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      autovalidateMode: _addAutovalidateMode,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      hint: const Text(AppConstants.statusDropdownHint),
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
                  ],
                ),
                const SizedBox(height: 14),

                // Rating (optional)
                AppTextField(
                  controller: _ratingController,
                  label: 'Rating (optional, 0-5)',
                  hint: 'Enter rating 0..5',
                  keyboardType: TextInputType.number,
                  validator: AppValidators.validateRating,
                ),
                const SizedBox(height: 14),

                // Notes (optional)
                AppTextField(
                  controller: _notesController,
                  label: 'Notes (optional, max 300 characters)',
                  hint: 'Optional notes...',
                  maxLines: 2,
                  validator: AppValidators.validateNotes,
                ),
                const SizedBox(height: 18),

                // Submit Button
                AppButton(
                  text: 'Add Book',
                  icon: Icons.add,
                  onPressed: _submitAddBook,
                  isLoading: _isAdding,
                  width: double.infinity,
                ),

                // Error message on Add Form
                if (_addFormError != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _addFormError!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterAndSummaryCard(BooksProvider provider) {
    final statusBreakdown = provider.statusBreakdown;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Box
            TextField(
              controller: _searchController,
              onChanged: (val) {
                provider.setSearchQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search by title or author...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Dropdown filters row: Genre and Status
            Row(
              children: [
                // Genre Filter Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Genre filter',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: provider.selectedGenre,
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        items: ['All', ...AppConstants.genres]
                            .map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g, style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) provider.setGenre(val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Status Filter Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status filter',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: provider.selectedStatus,
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        items: ['All', ...AppConstants.statuses]
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) provider.setStatus(val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Favorites only Switch and Clear button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: provider.favoritesOnly,
                      onChanged: (val) {
                        provider.setFavoritesOnly(val);
                      },
                    ),
                    const Text(
                      'favorites only',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text(
                    'Clear',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearFilters();
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // SUMMARY SECTION
            // Describes the books CURRENTLY SHOWN:
            // text "Books: N", text "Favorites: N" (plain integers)
            // breakdown with one row per status that appears (name + count), most books first;
            // ties order: To Read, Reading, Finished.
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Books: ${provider.currentBooksCount}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Favorites: ${provider.currentFavoritesCount}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (statusBreakdown.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Breakdown',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...statusBreakdown.map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${entry.value}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
